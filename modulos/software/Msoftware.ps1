# ============================
#   IMPORTAR MODULOS DE LOGGING
# ============================

. ".\modulos\logging-basico.ps1"
. ".\modulos\logging-detallado.ps1"


#=================================================================

#FUNCIONES

#==================================================================

#VARIABLES QUE SE VAN A USAR CONSTANTEMENTE LOGS Y LA RUTA DE LOS ARCHIVOS TXT QUE CONTIENEN LOS ID DE LAS APPS PARA WINGET

$listaPath = "$PSScriptRoot\listas_software\"
$logPath = "$PSScriptRoot\logs\software.log"
$numJobsMaximos = [Math]::Min([Environment]::ProcessorCount, 4)  # Limitar a 4 jobs máximo para no saturar

if (!(Test-Path ".\logs")) { New-Item -ItemType Directory -Path ".\logs" | Out-Null }

# --- Función auxiliar para instalar una app (usada en jobs) ---
function Instalar-Aplicacion {
    param(
        [string]$AppId,
        [string]$LogPath
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $timestamp | Out-File -Append -FilePath $LogPath -Encoding UTF8
    "[INICIO] Instalando: $AppId" | Out-File -Append -FilePath $LogPath -Encoding UTF8
    
    $resultado = & {
        winget install $AppId --silent --accept-source-agreements --accept-package-agreements 2>&1
    } | Out-String
    
    $resultado | Out-File -Append -FilePath $LogPath -Encoding UTF8
    "[FIN] $AppId" | Out-File -Append -FilePath $LogPath -Encoding UTF8
    
    return @{
        App = $AppId
        Resultado = $resultado
        Exitoso = $LASTEXITCODE -eq 0
    }
}

# --- Instalar software por departamento (OPTIMIZADO CON PARALELO) ---

function instalar-departamento {
    Clear-Host
    Write-Host "=== INSTALACION DE SOFTWARE POR DEPARTAMENTO ===" -ForegroundColor Cyan

    Write-Host "`nSeleccione el departamento:"
    Write-Host "1) Basico"
    Write-Host "2) Ofimatica"
    Write-Host "3) Utilidades"
    Write-Host "4) Ventas"
    Write-Host "5) Marketing"
    Write-Host "6) Informatica"
    Write-Host "7) Drivers"
    Write-Host "0) Volver"

    $op = Read-Host "`nOpcion"

    switch ($op) {
        "1" { $archivo = "basico.txt" }
        "2" { $archivo = "ofimatica.txt" }
        "3" { $archivo = "utilidades.txt" }
        "4" { $archivo = "ventas.txt" }
        "5" { $archivo = "marketing.txt" }
        "6" { $archivo = "informatica.txt" }
        "7" { $archivo = "drivers.txt" }
        "0" { return }
        default { Write-Host "Opcion no valida." -ForegroundColor Red; Pause; return }
    }

    $ruta = "$listaPath$archivo"

    if (!(Test-Path $ruta)) {
        Write-Host "ERROR: No se encontro la lista $archivo" -ForegroundColor Red
        return
    }

    $programas = @(Get-Content $ruta | Where-Object { $_.Trim() -ne "" })
    
    if ($programas.Count -eq 0) {
        Write-Host "ERROR: La lista de programas esta vacia." -ForegroundColor Red
        return
    }

    Clear-Host
    Write-Host "=== INSTALACION EN PARALELO ===" -ForegroundColor Green
    Write-Host "Total de aplicaciones: $($programas.Count)" -ForegroundColor Yellow
    Write-Host "Instalaciones simultáneas: $numJobsMaximos`n" -ForegroundColor Yellow
    
    $fechaInicio = Get-Date
    
    # Array para almacenar jobs
    $jobs = @()
    $indicePrograma = 0
    $completados = 0
    
    # Lanzar trabajo inicial
    while ($jobs.Count -lt $numJobsMaximos -and $indicePrograma -lt $programas.Count) {
        $app = $programas[$indicePrograma]
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ▶ INICIANDO: $app" -ForegroundColor Cyan
        
        $job = Start-Job -ScriptBlock ${function:Instalar-Aplicacion} -ArgumentList $app, $logPath -Name "Install-$app"
        $jobs += $job
        $indicePrograma++
    }
    
    # Procesar trabajos conforme terminen
    while ($jobs.Count -gt 0 -or $indicePrograma -lt $programas.Count) {
        $jobsCompletados = @($jobs | Where-Object { $_.State -eq "Completed" })
        
        # Procesar todos los jobs completados
        foreach ($jobCompleted in $jobsCompletados) {
            $resultado = Receive-Job -Job $jobCompleted -ErrorAction SilentlyContinue
            $completados++
            
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ✓ FINALIZADA: $($jobCompleted.Name)" -ForegroundColor Green
            
            # Eliminar el job completado
            Remove-Job -Job $jobCompleted -Force
            $jobs = @($jobs | Where-Object { $_.Id -ne $jobCompleted.Id })
        }
        
        # Lanzar siguiente trabajo si hay más disponibilidad
        while ($jobs.Count -lt $numJobsMaximos -and $indicePrograma -lt $programas.Count) {
            $app = $programas[$indicePrograma]
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ▶ INICIANDO: $app" -ForegroundColor Cyan
            
            $newJob = Start-Job -ScriptBlock ${function:Instalar-Aplicacion} -ArgumentList $app, $logPath -Name "Install-$app"
            $jobs += $newJob
            $indicePrograma++
        }
        
        # Mostrar progreso
        $pendientes = $programas.Count - $completados
        Write-Host "`r[PROGRESO] $completados/$($programas.Count) completadas | Pendientes: $pendientes" -ForegroundColor Yellow -NoNewline
        
        Start-Sleep -Milliseconds 500
    }
    
    $fechaFin = Get-Date
    $duracion = $fechaFin - $fechaInicio
    
    Write-Host "`n"
    Write-Host "✓ INSTALACION COMPLETADA DEL DEPARTAMENTO SELECCIONADO" -ForegroundColor Green
    Write-Host "Duracion total: $($duracion.Minutes)m $($duracion.Seconds)s" -ForegroundColor Green
    
    Pause
}
    
#=====================================================================================

# --- Instalacion personalizada (MEJORADA CON FEEDBACK) ---

function instalar-personalizado {
    Clear-Host
    Write-Host "=== INSTALACION PERSONALIZADA ===" -ForegroundColor Cyan

    Write-Host "`nProgramas recomendados:" -ForegroundColor Yellow
    Write-Host "1) Google.Chrome"
    Write-Host "2) Mozilla.Firefox"
    Write-Host "3) 7zip.7zip"
    Write-Host "4) Notepad++.Notepad++"
    Write-Host "5) Microsoft.VisualStudioCode"
    Write-Host "6) Adobe.Acrobat.Reader.64-bit"
    Write-Host "7) Python.Python.3"
    Write-Host "8) Git.Git"
    Write-Host "9) VideoLAN.VLC"
    Write-Host "10) WinRAR.WinRAR"

    Write-Host ""
    $id = Read-Host "Introduce el ID de Winget del programa a instalar (pueden ser distintos a los presentados)"
    
    if ([string]::IsNullOrWhiteSpace($id)) {
        Write-Host "ERROR: No se proporcionó ningun ID." -ForegroundColor Red
        Pause
        return
    }
    
    Clear-Host
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ▶ INICIANDO INSTALACION: $id" -ForegroundColor Cyan
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $timestamp | Out-File -Append -FilePath $logPath -Encoding UTF8
    "[INICIO] Instalando: $id" | Out-File -Append -FilePath $logPath -Encoding UTF8
    
    $job = Start-Job -ScriptBlock {
        param($AppId, $LogPath)
        winget install $AppId --silent --accept-source-agreements --accept-package-agreements 2>&1 | Tee-Object -Append -FilePath $LogPath
    } -ArgumentList $id, $logPath
    
    # Esperar con feedback visual
    $contador = 0
    while ((Get-Job -Id $job.Id).State -eq "Running") {
        $contador++
        $puntos = "." * ($contador % 4)
        Write-Host "`r[Instalando] $id$puntos                 " -ForegroundColor Yellow -NoNewline
        Start-Sleep -Milliseconds 300
    }
    
    Receive-Job -Job $job -ErrorAction SilentlyContinue | Out-File -Append -FilePath $logPath -Encoding UTF8
    "[FIN] $id" | Out-File -Append -FilePath $logPath -Encoding UTF8
    Remove-Job -Job $job -Force
    
    Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] ✓ INSTALACION COMPLETADA: $id" -ForegroundColor Green
    Pause
}

#====================================================================================================

# --- Actualizar software (MEJORADO CON FEEDBACK) ---

function actualizar-software {
    Clear-Host
    Write-Host "=== ACTUALIZANDO SOFTWARE ===" -ForegroundColor Cyan
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ▶ INICIANDO ACTUALIZACION DE TODAS LAS APLICACIONES..." -ForegroundColor Yellow
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $timestamp | Out-File -Append -FilePath $logPath -Encoding UTF8
    "[INICIO] Actualizacion de software" | Out-File -Append -FilePath $logPath -Encoding UTF8
    
    $job = Start-Job -ScriptBlock {
        param($LogPath)
        winget upgrade --all --silent --accept-source-agreements --accept-package-agreements 2>&1 | Tee-Object -Append -FilePath $LogPath
    } -ArgumentList $logPath
    
    # Mostrar progreso animado
    $contador = 0
    while ((Get-Job -Id $job.Id).State -eq "Running") {
        $contador++
        Write-Host "`rProcesando actualizaciones..." -ForegroundColor Yellow -NoNewline
        Start-Sleep -Milliseconds 300
    }

    Receive-Job -Job $job -ErrorAction SilentlyContinue | Out-File -Append -FilePath $logPath -Encoding UTF8
    "[FIN] Actualizacion completada" | Out-File -Append -FilePath $logPath -Encoding UTF8
    Remove-Job -Job $job -Force

    Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] ✓ ACTUALIZACION COMPLETADA" -ForegroundColor Green
    Pause
}

#=============================================================================================

# --- Desinstalar software (MEJORADO) ---

function desinstalar-software {
    Clear-Host
    Write-Host "=== DESINSTALAR SOFTWARE ===" -ForegroundColor Cyan

    $id = Read-Host "Introduce el ID de Winget del programa a desinstalar"
    
    if ([string]::IsNullOrWhiteSpace($id)) {
        Write-Host "ERROR: No se proporcionó ningun ID." -ForegroundColor Red
        Pause
        return
    }
    
    Clear-Host
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ▶ INICIANDO DESINSTALACION: $id" -ForegroundColor Yellow
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $timestamp | Out-File -Append -FilePath $logPath -Encoding UTF8
    "[INICIO] Desinstalando: $id" | Out-File -Append -FilePath $logPath -Encoding UTF8
    
    $job = Start-Job -ScriptBlock {
        param($AppId, $LogPath)
        winget uninstall $AppId 2>&1 | Tee-Object -Append -FilePath $LogPath
    } -ArgumentList $id, $logPath
    
    # Esperar con feedback
    $contador = 0
    while ((Get-Job -Id $job.Id).State -eq "Running") {
        $contador++
        $puntos = "." * ($contador % 4)
        Write-Host "`r[Desinstalando] $id$puntos                 " -ForegroundColor Yellow -NoNewline
        Start-Sleep -Milliseconds 300
    }
    
    Receive-Job -Job $job -ErrorAction SilentlyContinue | Out-File -Append -FilePath $logPath -Encoding UTF8
    "[FIN] $id" | Out-File -Append -FilePath $logPath -Encoding UTF8
    Remove-Job -Job $job -Force
    
    Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] ✓ DESINSTALACION COMPLETADA: $id" -ForegroundColor Green
    Pause
}

#=============================================================================

# --- Listar software instalado (MEJORADO) ---

function listar-software {
    Clear-Host
    Write-Host "=== SOFTWARE INSTALADO ===" -ForegroundColor Cyan
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ▶ Obteniendo lista de aplicaciones instaladas..." -ForegroundColor Yellow
    
    $job = Start-Job -ScriptBlock {
        winget list 2>&1
    }
    
    # Mostrar progreso
    $contador = 0
    while ((Get-Job -Id $job.Id).State -eq "Running") {
        $contador++
        Write-Host "`rLeyendo aplicaciones..." -ForegroundColor Yellow -NoNewline
        Start-Sleep -Milliseconds 300
    }
    
    Write-Host "`n" -ForegroundColor Yellow
    Receive-Job -Job $job -ErrorAction SilentlyContinue
    Remove-Job -Job $job -Force
    
    Pause
}



#===================================================================

# --- Ver logs (MEJORADO) ---

function ver-logs {
    Clear-Host
    Write-Host "=== LOGS DE SOFTWARE ===" -ForegroundColor Cyan

    if (Test-Path $logPath) {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Leyendo logs..." -ForegroundColor Yellow
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
        Get-Content $logPath
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    } else {
        Write-Host "No hay logs disponibles." -ForegroundColor Yellow
    }
    
    Pause
}


#======================================================================================



#========================   MENU  ==========================================

do {
    Clear-Host
    Write-Host "===== GESTION DE SOFTWARE =====" -ForegroundColor Cyan
    Write-Host "1) Instalar software por departamento"
    Write-Host "2) Instalacion personalizada"
    Write-Host "3) Actualizar software"
    Write-Host "4) Desinstalar software"
    Write-Host "5) Listar software instalado"
    Write-Host "6) Ver logs"
    Write-Host "0) Salir" -ForegroundColor Cyan

    $op = Read-Host "`nSelecciona una opcion"

    switch ($op) {
        "1" { instalar-departamento }
        "2" { instalar-personalizado }
        "3" { actualizar-software }
        "4" { desinstalar-software }
        "5" { listar-software }
        "6" { ver-logs }
        "0" { break }
        default { Write-Host "Opcion no valida." -ForegroundColor Red; Pause }
    }

} while ($op -ne "0")
