#=================================================================
# MsoftwareRealG.ps1
# Version limpia y comentada del modulo de gestion de software
# - Sin caracteres extranos
# - Comentarios explicativos en funciones avanzadas
# - Manejo de logs y ejecucion en paralelo para instalaciones
#=================================================================

# Ruta base para listas y logs (relativa al script)
$listaPath = Join-Path -Path $PSScriptRoot -ChildPath 'listas_software'
$logPath = Join-Path -Path $PSScriptRoot -ChildPath 'logs\software.log'

# Numero maximo de trabajos en paralelo (no saturar CPU)
$numJobsMaximos = [Math]::Min([Environment]::ProcessorCount, 4)

# Asegurar que el directorio de logs exista
if (-not (Test-Path (Join-Path $PSScriptRoot 'logs'))) {
    New-Item -ItemType Directory -Path (Join-Path $PSScriptRoot 'logs') | Out-Null
}

# ---------------------------------------------------------------
# Instalar-Aplicacion
# Funcion auxiliar que realiza la instalacion de una unica aplicacion
# Argumentos:
#  - AppId: Identificador de winget (string)
#  - LogPath: Ruta al fichero de logs donde se registrara la salida
# Devuelve: un objeto con App, Resultado y Exitoso
# ---------------------------------------------------------------
function Instalar-Aplicacion {
    param(
        [string]$AppId,
        [string]$LogPath
    )

    # Marca temporal y registro inicial
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp" | Out-File -Append -FilePath $LogPath -Encoding UTF8
    "[INICIO] Instalando: $AppId" | Out-File -Append -FilePath $LogPath -Encoding UTF8

    # Ejecutar winget y capturar salida
    $resultado = & { winget install $AppId --silent --accept-source-agreements --accept-package-agreements 2>&1 } | Out-String

    # Guardar resultado en log y marcar fin
    $resultado | Out-File -Append -FilePath $LogPath -Encoding UTF8
    "[FIN] $AppId" | Out-File -Append -FilePath $LogPath -Encoding UTF8

    return [PSCustomObject]@{
        App = $AppId
        Resultado = $resultado
        Exitoso = ($LASTEXITCODE -eq 0)
    }
}

# ---------------------------------------------------------------
# instalar-departamento
# Lee una lista de IDs desde un fichero por departamento y los instala
# en paralelo usando jobs. Controla el numero maximo de trabajos
# ---------------------------------------------------------------
function instalar-departamento {
    Clear-Host
    Write-Host "=== INSTALACION DE SOFTWARE POR DEPARTAMENTO ===" -ForegroundColor Cyan

    # Mostrar opciones y leer eleccion
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
        "1" { $archivo = 'basico.txt' }
        "2" { $archivo = 'ofimatica.txt' }
        "3" { $archivo = 'utilidades.txt' }
        "4" { $archivo = 'ventas.txt' }
        "5" { $archivo = 'marketing.txt' }
        "6" { $archivo = 'informatica.txt' }
        "7" { $archivo = 'drivers.txt' }
        "0" { return }
        default { Write-Host "Opcion no valida." -ForegroundColor Red; Pause; return }
    }

    $ruta = Join-Path -Path $listaPath -ChildPath $archivo
    if (-not (Test-Path $ruta)) {
        Write-Host "ERROR: No se encontro la lista $archivo" -ForegroundColor Red
        Pause
        return
    }

    $programas = @(Get-Content -Path $ruta | Where-Object { $_.Trim() -ne '' })
    if ($programas.Count -eq 0) {
        Write-Host "ERROR: La lista de programas esta vacia." -ForegroundColor Red
        Pause
        return
    }

    Clear-Host
    Write-Host "=== INSTALACION EN PARALELO ===" -ForegroundColor Green
    Write-Host "Total de aplicaciones: $($programas.Count)" -ForegroundColor Yellow
    Write-Host "Instalaciones simultaneas: $numJobsMaximos`n" -ForegroundColor Yellow

    $fechaInicio = Get-Date

    # Control de jobs en ejecucion y cola de programas
    $jobs = @()
    $indicePrograma = 0
    $completados = 0

    # Iniciar los primeros trabajos hasta el limite
    while ($jobs.Count -lt $numJobsMaximos -and $indicePrograma -lt $programas.Count) {
        $app = $programas[$indicePrograma]
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ▶ INICIANDO: $app" -ForegroundColor Cyan
        $job = Start-Job -ScriptBlock ${function:Instalar-Aplicacion} -ArgumentList $app, $logPath -Name "Install-$app"
        $jobs += $job
        $indicePrograma++
    }

    # Ciclo principal: procesar completados y lanzar nuevos
    while ($jobs.Count -gt 0 -or $indicePrograma -lt $programas.Count) {
        $jobsCompletados = @($jobs | Where-Object { $_.State -eq 'Completed' })

        foreach ($jobCompleted in $jobsCompletados) {
            Receive-Job -Job $jobCompleted -ErrorAction SilentlyContinue | Out-Null
            $completados++
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ✓ FINALIZADA: $($jobCompleted.Name)" -ForegroundColor Green
            Remove-Job -Job $jobCompleted -Force
            $jobs = @($jobs | Where-Object { $_.Id -ne $jobCompleted.Id })
        }

        while ($jobs.Count -lt $numJobsMaximos -and $indicePrograma -lt $programas.Count) {
            $app = $programas[$indicePrograma]
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ▶ INICIANDO: $app" -ForegroundColor Cyan
            $newJob = Start-Job -ScriptBlock ${function:Instalar-Aplicacion} -ArgumentList $app, $logPath -Name "Install-$app"
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
    Write-Host "✓ INSTALACION COMPLETADA DEL DEPARTAMENTO SELECCIONADO" -ForegroundColor Green
    Write-Host "Duracion total: $($duracion.Minutes)m $($duracion.Seconds)s" -ForegroundColor Green
    Pause
}

# ---------------------------------------------------------------
# instalar-personalizado
# Permite al usuario introducir un ID de winget y lo instala con
# feedback visual mientras el job se ejecuta.
# ---------------------------------------------------------------
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
        Write-Host "ERROR: No se proporciono ningun ID." -ForegroundColor Red
        Pause
        return
    }

    Clear-Host
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ▶ INICIANDO INSTALACION: $id" -ForegroundColor Cyan
    "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))" | Out-File -Append -FilePath $logPath -Encoding UTF8
    "[INICIO] Instalando: $id" | Out-File -Append -FilePath $logPath -Encoding UTF8

    # Ejecutar la instalacion en un Job y mostrar puntos de progreso
    $job = Start-Job -ScriptBlock {
        param($AppId, $LogPath)
        winget install $AppId --silent --accept-source-agreements --accept-package-agreements 2>&1 | Tee-Object -Append -FilePath $LogPath
    } -ArgumentList $id, $logPath

    $contador = 0
    while ((Get-Job -Id $job.Id).State -eq 'Running') {
        $contador++
        $puntos = '.' * ($contador % 4)
        Write-Host "`r[Instalando] $id$puntos                 " -ForegroundColor Yellow -NoNewline
        Start-Sleep -Milliseconds 300
    }

    Receive-Job -Job $job -ErrorAction SilentlyContinue | Out-File -Append -FilePath $logPath -Encoding UTF8
    "[FIN] $id" | Out-File -Append -FilePath $logPath -Encoding UTF8
    Remove-Job -Job $job -Force

    Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] ✓ INSTALACION COMPLETADA: $id" -ForegroundColor Green
    Pause
}

# ---------------------------------------------------------------
# actualizar-software
# Lanza `winget upgrade --all` en background y muestra progreso.
# ---------------------------------------------------------------
function actualizar-software {
    Clear-Host
    Write-Host "=== ACTUALIZANDO SOFTWARE ===" -ForegroundColor Cyan
    "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))" | Out-File -Append -FilePath $logPath -Encoding UTF8
    "[INICIO] Actualizacion de software" | Out-File -Append -FilePath $logPath -Encoding UTF8

    $job = Start-Job -ScriptBlock {
        param($LogPath)
        winget upgrade --all --silent --accept-source-agreements --accept-package-agreements 2>&1 | Tee-Object -Append -FilePath $LogPath
    } -ArgumentList $logPath

    while ((Get-Job -Id $job.Id).State -eq 'Running') {
        Write-Host "`rProcesando actualizaciones..." -ForegroundColor Yellow -NoNewline
        Start-Sleep -Milliseconds 300
    }

    Receive-Job -Job $job -ErrorAction SilentlyContinue | Out-File -Append -FilePath $logPath -Encoding UTF8
    "[FIN] Actualizacion completada" | Out-File -Append -FilePath $logPath -Encoding UTF8
    Remove-Job -Job $job -Force

    Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] ✓ ACTUALIZACION COMPLETADA" -ForegroundColor Green
    Pause
}

# ---------------------------------------------------------------
# desinstalar-software
# Desinstala un paquete dado su ID y registra la salida
# ---------------------------------------------------------------
function desinstalar-software {
    Clear-Host
    Write-Host "=== DESINSTALAR SOFTWARE ===" -ForegroundColor Cyan

    $id = Read-Host "Introduce el ID de Winget del programa a desinstalar"
    if ([string]::IsNullOrWhiteSpace($id)) {
        Write-Host "ERROR: No se proporciono ningun ID." -ForegroundColor Red
        Pause
        return
    }

    Clear-Host
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ▶ INICIANDO DESINSTALACION: $id" -ForegroundColor Yellow
    "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))" | Out-File -Append -FilePath $logPath -Encoding UTF8
    "[INICIO] Desinstalando: $id" | Out-File -Append -FilePath $logPath -Encoding UTF8

    $job = Start-Job -ScriptBlock {
        param($AppId, $LogPath)
        winget uninstall $AppId 2>&1 | Tee-Object -Append -FilePath $LogPath
    } -ArgumentList $id, $logPath

    $contador = 0
    while ((Get-Job -Id $job.Id).State -eq 'Running') {
        $contador++
        $puntos = '.' * ($contador % 4)
        Write-Host "`r[Desinstalando] $id$puntos                 " -ForegroundColor Yellow -NoNewline
        Start-Sleep -Milliseconds 300
    }

    Receive-Job -Job $job -ErrorAction SilentlyContinue | Out-File -Append -FilePath $logPath -Encoding UTF8
    "[FIN] $id" | Out-File -Append -FilePath $logPath -Encoding UTF8
    Remove-Job -Job $job -Force

    Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] ✓ DESINSTALACION COMPLETADA: $id" -ForegroundColor Green
    Pause
}

# ---------------------------------------------------------------
# listar-software
# Muestra la salida de `winget list` en segundo plano mientras
# muestra un indicador de progreso.
# ---------------------------------------------------------------
function listar-software {
    Clear-Host
    Write-Host "=== SOFTWARE INSTALADO ===" -ForegroundColor Cyan
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] ▶ Obteniendo lista de aplicaciones instaladas..." -ForegroundColor Yellow

    $job = Start-Job -ScriptBlock { winget list 2>&1 }
    while ((Get-Job -Id $job.Id).State -eq 'Running') {
        Write-Host "`rLeyendo aplicaciones..." -ForegroundColor Yellow -NoNewline
        Start-Sleep -Milliseconds 300
    }

    Write-Host "`n" -ForegroundColor Yellow
    Receive-Job -Job $job -ErrorAction SilentlyContinue
    Remove-Job -Job $job -Force
    Pause
}

# ---------------------------------------------------------------
# ver-logs
# Muestra el contenido del fichero de log si existe
# ---------------------------------------------------------------
function ver-logs {
    Clear-Host
    Write-Host "=== LOGS DE SOFTWARE ===" -ForegroundColor Cyan

    if (Test-Path $logPath) {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Leyendo logs..." -ForegroundColor Yellow
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
        Get-Content -Path $logPath
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    } else {
        Write-Host "No hay logs disponibles." -ForegroundColor Yellow
    }

    Pause
}

# ---------------------------------------------------------------
# Menu principal
# ---------------------------------------------------------------
do {
    Clear-Host
    Write-Host "===== GESTION DE SOFTWARE (RealG) =====" -ForegroundColor Cyan
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

} while ($op -ne '0')
