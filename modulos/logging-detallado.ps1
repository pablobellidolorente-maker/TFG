<#
.SYNOPSIS
    Sistema de Logging Detallado para TFG-AutoDeploy.

.DESCRIPTION
    Módulo para registrar todos los pasos de la ejecución.
    El archivo de log detallado SIEMPRE se guarda automáticamente.

.EXAMPLE
    Write-DetailedLog "Verificando permisos de administrador..."
    Invoke-DetailedAction -Action $scriptblock -Description "Cambiar nombre"
#>

# ============================
#   CONFIGURACION GLOBAL
# ============================

$Global:ProjectRoot = Split-Path -Parent $PSScriptRoot
$Global:LogBasePath = Join-Path $ProjectRoot "logs"

# Crear carpeta de logs si no existe
if (-not (Test-Path $Global:LogBasePath)) {
    New-Item -Path $Global:LogBasePath -ItemType Directory | Out-Null
}

# ============================
#   FUNCION: Write-DetailedLog
# ============================
<#
.SYNOPSIS
    Escribe mensajes detallados en el archivo de log.
    SIEMPRE guarda en el archivo.

.PARAMETER Message
    El mensaje a registrar.

.PARAMETER LineNumber
    Número de línea si es necesario.
    
.PARAMETER ConsoleOutput
    Si se activa, también muestra el log en consola.
#>
function Write-DetailedLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [int]$LineNumber = $null,
        
        [switch]$ConsoleOutput
    )

    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logDate = Get-Date -Format "yyyy-MM-dd"
    
    # Construir el mensaje con línea si existe
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
<#
.SYNOPSIS
    Ejecuta una acción y registra todos los pasos en el archivo detallado.

.PARAMETER Action
    El scriptblock a ejecutar.
    
.PARAMETER Description
    Descripción de lo que hace la acción.
    
.EXAMPLE
    Invoke-DetailedAction -Action { Rename-Computer -NewName "EQUIPO" } `
                          -Description "Cambiar nombre"
#>
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
        
        # Ejecutar acción
        $result = & $Action
        
        # Registrar éxito
        Write-DetailedLog -Message "Proceso finalizado exitosamente: $Description"
        
        return $result
        
    } catch {
        # Obtener información del error
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
<#
.SYNOPSIS
    Muestra un resumen de los logs generados.

.PARAMETER Date
    Fecha para la que mostrar los logs (por defecto, hoy).
    
.EXAMPLE
    Get-LogSummary
    Get-LogSummary -Date "2026-05-16"
#>
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
    
    # Contar líneas en cada archivo
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
<#
.SYNOPSIS
    Verifica si el script se está ejecutando con permisos de administrador.
#>
function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ============================
#   FUNCION: Require-Admin
# ============================
<#
.SYNOPSIS
    Verifica permisos de admin y sale si no los tiene.
#>
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
<#
.SYNOPSIS
    Importa un archivo de configuración con verificación.

.PARAMETER Path
    Ruta del archivo de configuración.
    
.EXAMPLE
    $config = Import-ConfigFile -Path ".\config\settings.conf"
#>
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

# ============================
#   EXPORTAR FUNCIONES
# ============================

Export-ModuleMember -Function @(
    'Write-DetailedLog',
    'Invoke-DetailedAction',
    'Get-LogSummary',
    'Test-IsAdmin',
    'Require-Admin',
    'Import-ConfigFile'
) -Variable @(
    'ProjectRoot',
    'LogBasePath'
)
