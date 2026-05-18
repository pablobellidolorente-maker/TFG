<#
.SYNOPSIS
    Sistema de Logging Básico para TFG-AutoDeploy.

.DESCRIPTION
    Módulo para registrar solo los eventos principales:
    - Inicio de procesos
    - Finalización exitosa
    - Errores con número de línea

.EXAMPLE
    Write-BasicLog -Message "Configurando equipo" -Type "INICIO"
    Write-BasicLog -Message "Equipo configurado correctamente" -Type "EXITO"
    Write-BasicLog -Message "Fallo en la configuración" -Type "ERROR" -LineNumber 45
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
#   FUNCION: Write-BasicLog
# ============================
<#
.SYNOPSIS
    Escribe mensajes en el archivo de log básico.

.PARAMETER Message
    El mensaje a registrar.

.PARAMETER Type
    Tipo de mensaje: INICIO, EXITO, ERROR
    
.PARAMETER LineNumber
    Número de línea donde ocurrió el evento (especialmente para errores).
    
.PARAMETER ConsoleOutput
    Si se activa, también muestra el log en consola.
#>
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
    
    # Construir el mensaje con línea si existe
    $lineInfo = if ($LineNumber) { " [Linea: $LineNumber]" } else { "" }
    $logEntry = "[$timestamp] [$Type]$lineInfo $Message"
    
    # Archivo de log básico
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
<#
.SYNOPSIS
    Ejecuta una acción con logging básico automático.

.PARAMETER Action
    El scriptblock a ejecutar.
    
.PARAMETER Description
    Descripción de lo que hace la acción.
    
.EXAMPLE
    Invoke-BasicAction -Action { Rename-Computer -NewName "EQUIPO-NUEVO" } `
                       -Description "Cambiar nombre del equipo"
#>
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
        
        # Ejecutar acción
        $result = & $Action
        
        # Registrar éxito
        Write-BasicLog -Message "Se ejecuto correctamente: $Description" -Type "EXITO" -ConsoleOutput
        
        return $result
        
    } catch {
        # Obtener información del error
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
        Write-BasicLog -Message "El script requiere privilegios de administrador." -Type "ERROR" -ConsoleOutput
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

# ============================
#   EXPORTAR FUNCIONES
# ============================

Export-ModuleMember -Function @(
    'Write-BasicLog',
    'Invoke-BasicAction',
    'Test-IsAdmin',
    'Require-Admin',
    'Import-ConfigFile'
) -Variable @(
    'ProjectRoot',
    'LogBasePath'
)
