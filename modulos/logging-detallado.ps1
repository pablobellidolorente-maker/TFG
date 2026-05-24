# ============================
#   CONFIGURACION GLOBAL
# ============================

$Global:ProjectRoot = Split-Path -Parent $PSScriptRoot
$Global:LogBasePath = Join-Path $ProjectRoot "logs"

# Crear carpeta de logs si no existe
if (-not (Test-Path $Global:LogBasePath)) {
    New-Item -Path $Global:LogBasePath -ItemType Directory | Out-Null
}

# Asegurar que exista el archivo de log detallado del dia actual
$Global:DetailedLogFilePath = Join-Path $Global:LogBasePath ("detallado_$(Get-Date -Format 'yyyy-MM-dd').log")
if (-not (Test-Path $Global:DetailedLogFilePath)) {
    New-Item -Path $Global:DetailedLogFilePath -ItemType File | Out-Null
}

# ============================
#   FUNCION: Write-DetailedLog
# ============================

function Write-DetailedLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [int]$LineNumber = $null,
        
        [switch]$ConsoleOutput
    )

    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logDate = Get-Date -Format "yyyy-MM-dd"
    
    # Construir el mensaje con linea si existe
    $lineInfo = if ($LineNumber) { " [Linea: $LineNumber]" } else { "" }
    $logEntry = "[$timestamp] [DETALLE]$lineInfo $Message"
    
    # Archivo de log detallado
    $logFileName = "detallado_$logDate.log"
    $logFilePath = Join-Path $Global:LogBasePath $logFileName
    
    # SIEMPRE escribir en archivo
    try {
        Add-Content -Path $logFilePath -Value $logEntry -Encoding UTF8 -ErrorAction Stop
    } catch {
        Write-Host "Error escribiendo en log: $_"
    }
    
    # Mostrar en consola si se solicita
    if ($ConsoleOutput) {
        Write-Host "[$timestamp] [DETALLE]$lineInfo $Message"
    }
}

# ============================
#   FUNCION: Invoke-DetailedAction
# ============================

function Invoke-DetailedAction {
    param(
        [Parameter(Mandatory=$true)]
        [scriptblock]$Action,

        [Parameter(Mandatory=$true)]
        [string]$Description
    )
    
    try {
        # Registrar inicio
        Write-DetailedLog -Message "Iniciando proceso: $Description"
        
        # Ejecutar accion
        $result = & $Action
        
        # Registrar exito
        Write-DetailedLog -Message "Proceso finalizado exitosamente: $Description"
        
        return $result
        
    } catch {
        # Obtener informacion del error
        $errorLine = $_.InvocationInfo.ScriptLineNumber
        $errorMsg = $_.Exception.Message
        $errorType = $_.Exception.GetType().Name
        $stackTrace = $_.ScriptStackTrace
        
        # Registrar error en detalle
        Write-DetailedLog -Message "Error en '$Description': $errorType - $errorMsg" `
                        -LineNumber $errorLine
        
        Write-DetailedLog -Message "Stack Trace: $stackTrace"
        
        throw $_
    }
}

# ============================
#   FUNCION: Get-LogSummary
# ============================

function Get-LogSummary {
    param(
        [string]$Date = (Get-Date -Format "yyyy-MM-dd")
    )
    
    Write-Host ""
    Write-Host "RESUMEN DE LOGS - $Date"
    Write-Host "=================================================="
    Write-Host ""
    
    $basicLog = Join-Path $Global:LogBasePath "basico_$Date.log"
    $detailedLog = Join-Path $Global:LogBasePath "detallado_$Date.log"
    
    # Contar lineas en cada archivo
    $basicCount = if (Test-Path $basicLog) { (Get-Content $basicLog | Measure-Object -Line).Lines } else { 0 }
    $detailedCount = if (Test-Path $detailedLog) { (Get-Content $detailedLog | Measure-Object -Line).Lines } else { 0 }
    
    Write-Host "Log Basico:      $basicCount lineas"
    Write-Host "Log Detallado:   $detailedCount lineas"
    
    Write-Host ""
    Write-Host "Ubicacion: $Global:LogBasePath"
    Write-Host ""
}

# ============================
#   FUNCION: Test-IsAdmin
# ============================

function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ============================
#   FUNCION: Require-Admin
# ============================

function Require-Admin {
    if (-not (Test-IsAdmin)) {
        Write-DetailedLog -Message "El script requiere privilegios de administrador."
        Write-Host "Este script debe ejecutarse como administrador."
        exit 1
    }
}

# ============================
#   FUNCION: Import-ConfigFile
# ============================

function Import-ConfigFile {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        Write-DetailedLog -Message "Archivo de configuracion no encontrado: $Path"
        throw "No se encontro el archivo de configuracion: $Path"
    }

    Write-DetailedLog -Message "Cargando archivo de configuracion: $Path"
    
    return Get-Content -Path $Path -Encoding UTF8
}

