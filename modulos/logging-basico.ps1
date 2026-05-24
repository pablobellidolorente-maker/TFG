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
#   FUNCION: Write-BasicLog
# ============================

function Write-BasicLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [ValidateSet("INICIO", "EXITO", "ERROR")]
        [string]$Type = "INICIO",
        
        [int]$LineNumber = $null,
        
        [switch]$ConsoleOutput
    )

    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logDate = Get-Date -Format "yyyy-MM-dd"
    
    # Construir el mensaje con linea si existe
    $lineInfo = if ($LineNumber) { " [Linea: $LineNumber]" } else { "" }
    $logEntry = "[$timestamp] [$Type]$lineInfo $Message"
    
    # Archivo de log basico
    $logFileName = "basico_$logDate.log"
    $logFilePath = Join-Path $Global:LogBasePath $logFileName
    
    # Escribir en archivo
    try {
        Add-Content -Path $logFilePath -Value $logEntry -Encoding UTF8 -ErrorAction Stop
    } catch {
        Write-Host "Error escribiendo en log: $_"
    }
    
    # Mostrar en consola si se solicita
    if ($ConsoleOutput) {
        Write-Host "[$timestamp] [$Type]$lineInfo $Message"
    }
}

# ============================
#   FUNCION: Invoke-BasicAction
# ============================

function Invoke-BasicAction {
    param(
        [Parameter(Mandatory=$true)]
        [scriptblock]$Action,

        [Parameter(Mandatory=$true)]
        [string]$Description
    )
    
    try {
        # Registrar inicio
        Write-BasicLog -Message "Empieza: $Description" -Type "INICIO" -ConsoleOutput
        
        # Ejecutar accion
        $result = & $Action
        
        # Registrar exito
        Write-BasicLog -Message "Se ejecuto correctamente: $Description" -Type "EXITO" -ConsoleOutput
        
        return $result
        
    } catch {
        # Obtener informacion del error
        $errorLine = $_.InvocationInfo.ScriptLineNumber
        $errorMsg = $_.Exception.Message
        
        # Registrar error
        Write-BasicLog -Message "Error en '$Description': $errorMsg" `
                       -Type "ERROR" `
                       -LineNumber $errorLine `
                       -ConsoleOutput
        
        throw $_
    }
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
        Write-BasicLog -Message "El script requiere privilegios de administrador." -Type "ERROR" -ConsoleOutput
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
        Write-BasicLog -Message "Archivo de configuracion no encontrado: $Path" `
                       -Type "ERROR" `
                       -ConsoleOutput
        throw "No se encontro el archivo de configuracion: $Path"
    }

    Write-BasicLog -Message "Cargando archivo de configuracion: $Path" `
                   -Type "INICIO" `
                   -ConsoleOutput
    
    return Get-Content -Path $Path -Encoding UTF8
}

