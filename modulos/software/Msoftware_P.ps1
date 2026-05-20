#==================================================================
# VARIABLES (sin logs)
$listaPath = "$PSScriptRoot\listas_software\"
$numJobsMaximos = [Math]::Min([Environment]::ProcessorCount, 4)

# --- Función auxiliar para instalar una app (usada en jobs) ---
function Instalar-Aplicacion {
    param(
        [string]$AppId
    )
    
    $resultado = & {
        winget install $AppId --silent --accept-source-agreements --accept-package-agreements 2>&1
    } | Out-String
    
    return @{
        App = $AppId
        Resultado = $resultado
        Exitoso = $LASTEXITCODE -eq 0
    }
}

# --- Instalar software por departamento ---
function instalar-departamento {
    Clear-Host
    Write-Host "=== INSTALACIÓN DE SOFTWARE POR DEPARTAMENTO ===" -ForegroundColor Cyan

    Write-Host "`nSeleccione el departamento:"
    Write-Host "1) Básico"
    Write-Host "2) Ofimática"
    Write-Host "3) Utilidades"
    Write-Host "4) Ventas"
    Write-Host "5) Marketing"
    Write-Host "6) Informática"
    Write-Host "7) Drivers"
    Write-Host "0) Volver"

    $op = Read-Host "`nOpción"

    switch ($op) {
        "1" { $archivo = "basico.txt" }
        "2" { $archivo = "ofimatica.txt" }
        "3" { $archivo = "utilidades.txt" }
        "4" { $archivo = "ventas.txt" }
        "5" { $archivo = "marketing.txt" }
        "6" { $archivo = "informatica.txt" }
        "7" { $archivo = "drivers.txt" }
        "0" { return }
        default { Write-Host "Opción no válida." -ForegroundColor Red; Pause; return }
    }

    $ruta = "$listaPath$archivo"

    if (!(Test-Path $ruta)) {
        Write-Host "ERROR: No se encontró la lista $archivo" -ForegroundColor Red
        return
    }

    $programas = @(Get-Content $ruta | Where-Object { $_.Trim() -ne "" })
    
    if ($programas.Count -eq 0) {
        Write-Host "ERROR: La lista de programas está vacía." -ForegroundColor Red
        return
    }

    Clear-Host
    Write-Host "=== INSTALACIÓN EN PARALELO ===" -ForegroundColor Green
    Write-Host "Total de aplicaciones: $($programas.Count)" -ForegroundColor Yellow
    Write-Host "Instalaciones simultáneas: $numJobsMaximos`n" -ForegroundColor Yellow
    
    $fechaInicio = Get-Date
    
    $jobs = @()
    $indicePrograma = 0
    $completados = 0
    
    while ($jobs.Count -lt $numJobsMaximos -and $indicePrograma -lt $programas.Count) {
        $app = $programas[$indicePrograma]
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ▶ INICIANDO: $app" -ForegroundColor Cyan
        
        $job = Start-Job -ScriptBlock ${function:Instalar-Aplicacion} -ArgumentList $app -Name "Install-$app"
        $jobs += $job
        $indicePrograma++
    }
    
    while ($jobs.Count -gt 0 -or $indicePrograma -lt $programas.Count) {
        $jobsCompletados = @($jobs | Where-Object { $_.State -eq "Completed" })
        
        foreach ($jobCompleted in $jobsCompletados) {
            $resultado = Receive-Job -Job $jobCompleted -ErrorAction SilentlyContinue
            $completados++
            
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ✓ FINALIZADA: $($jobCompleted.Name)" -ForegroundColor Green
            
            Remove-Job -Job $jobCompleted -Force
            $jobs = @($jobs | Where-Object { $_.Id -ne $jobCompleted.Id })
        }
        
        while ($jobs.Count -lt $numJobsMaximos -and $indicePrograma -lt $programas.Count) {
            $app = $programas[$indicePrograma]
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ▶ INICIANDO: $app" -ForegroundColor Cyan
            
            $newJob = Start-Job -ScriptBlock ${function:Instalar-Aplicacion} -ArgumentList $app -Name "Install-$app"
            $jobs += $newJob
            $indicePrograma++
        }
        
        $pendientes = $programas.Count - $completados
        Write-Host "`r[PROGRESO] $completados/$($programas.Count) completadas | Pendientes: $pendientes" -ForegroundColor Yellow -NoNewline
        
        Start-Sleep -Milliseconds 500
    }
    
    $fechaFin = Get-Date
    $duracion = $fechaFin - $fechaInicio
    
    Write-Host "`n"
    Write-Host "✓ INSTALACIÓN COMPLETADA DEL DEPARTAMENTO SELECCIONADO" -ForegroundColor Green
    Write-Host "Duración total: $($duracion.Minutes)m $($duracion.Seconds)s" -ForegroundColor Green
    
    Pause
}

# --- Instalación personalizada ---
function instalar-personalizado {
    Clear-Host
    Write-Host "=== INSTALACIÓN PERSONALIZADA ===" -ForegroundColor Cyan

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
    $id = Read-Host "Introduce el ID de Winget del programa a instalar"
    
    if ([string]::IsNullOrWhiteSpace($id)) {
        Write-Host "ERROR: No se proporcionó ningún ID." -ForegroundColor Red
        Pause
        return
    }
    
    Clear-Host
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ▶ INICIANDO INSTALACIÓN: $id" -ForegroundColor Cyan
    
    $job = Start-Job -ScriptBlock {
        param($AppId)
        winget install $AppId --silent --accept-source-agreements --accept-package-agreements 2>&1
    } -ArgumentList $id
    
    $contador = 0
    while ((Get-Job -Id $job.Id).State -eq "Running") {
        $contador++
        $puntos = "." * ($contador % 4)
        Write-Host "`r[Instalando] $id$puntos                 " -ForegroundColor Yellow -NoNewline
        Start-Sleep -Milliseconds 300
    }
    
    Receive-Job -Job $job -ErrorAction SilentlyContinue
    Remove-Job -Job $job -Force
    
    Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] ✓ INSTALACIÓN COMPLETADA: $id" -ForegroundColor Green
    Pause
}

# --- Actualizar software ---
function actualizar-software {
    Clear-Host
    Write-Host "=== ACTUALIZANDO SOFTWARE ===" -ForegroundColor Cyan
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ▶ INICIANDO ACTUALIZACIÓN..." -ForegroundColor Yellow
    
    $job = Start-Job -ScriptBlock {
        winget upgrade --all --silent --accept-source-agreements --accept-package-agreements 2>&1
    }
    
    $contador = 0
    while ((Get-Job -Id $job.Id).State -eq "Running") {
        $contador++
        Write-Host "`rProcesando actualizaciones..." -ForegroundColor Yellow -NoNewline
        Start-Sleep -Milliseconds 300
    }

    Receive-Job -Job $job -ErrorAction SilentlyContinue
    Remove-Job -Job $job -Force

    Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] ✓ ACTUALIZACIÓN COMPLETADA" -ForegroundColor Green
    Pause
}

# --- Desinstalar software ---
function desinstalar-software {
    Clear-Host
    Write-Host "=== DESINSTALAR SOFTWARE ===" -ForegroundColor Cyan

    $id = Read-Host "Introduce el ID de Winget del programa a desinstalar"
    
    if ([string]::IsNullOrWhiteSpace($id)) {
        Write-Host "ERROR: No se proporcionó ningún ID." -ForegroundColor Red
        Pause
        return
    }
    
    Clear-Host
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ▶ INICIANDO DESINSTALACIÓN: $id" -ForegroundColor Yellow
    
    $job = Start-Job -ScriptBlock {
        param($AppId)
        winget uninstall $AppId 2>&1
    } -ArgumentList $id
    
    $contador = 0
    while ((Get-Job -Id $job.Id).State -eq "Running") {
        $contador++
        $puntos = "." * ($contador % 4)
        Write-Host "`r[Desinstalando] $id$puntos                 " -ForegroundColor Yellow -NoNewline
        Start-Sleep -Milliseconds 300
    }
    
    Receive-Job -Job $job -ErrorAction SilentlyContinue
    Remove-Job -Job $job -Force
    
    Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] ✓ DESINSTALACIÓN COMPLETADA: $id" -ForegroundColor Green
    Pause
}

# --- Listar software ---
function listar-software {
    Clear-Host
    Write-Host "=== SOFTWARE INSTALADO ===" -ForegroundColor Cyan
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ▶ Obteniendo lista..." -ForegroundColor Yellow
    
    $job = Start-Job -ScriptBlock {
        winget list 2>&1
    }
    
    $contador = 0
    while ((Get-Job -Id $job.Id).State -eq "Running") {
        $contador++
        Write-Host "`rLeyendo aplicaciones..." -ForegroundColor Yellow -NoNewline
        Start-Sleep -Milliseconds 300
    }
    
    Write-Host "`n"
    Receive-Job -Job $job -ErrorAction SilentlyContinue
    Remove-Job -Job $job -Force
    
    Pause
}

# --- Ver logs (deshabilitado) ---
function ver-logs {
    Clear-Host
    Write-Host "No hay logs disponibles (función deshabilitada)." -ForegroundColor Yellow
    Pause
}

#========================   MENÚ  ==========================================

do {
    Clear-Host
    Write-Host "===== GESTIÓN DE SOFTWARE =====" -ForegroundColor Cyan
    Write-Host "1) Instalar software por departamento"
    Write-Host "2) Instalación personalizada"
    Write-Host "3) Actualizar software"
    Write-Host "4) Desinstalar software"
    Write-Host "5) Listar software instalado"
    Write-Host "6) Ver logs"
    Write-Host "0) Salir" -ForegroundColor Cyan

    $op = Read-Host "`nSelecciona una opción"

    switch ($op) {
        "1" { instalar-departamento }
        "2" { instalar-personalizado }
        "3" { actualizar-software }
        "4" { desinstalar-software }
        "5" { listar-software }
        "6" { ver-logs }
        "0" { break }
        default { Write-Host "Opción no válida." -ForegroundColor Red; Pause }
    }

} while ($op -ne "0")
