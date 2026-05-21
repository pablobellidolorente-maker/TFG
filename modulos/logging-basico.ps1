<#
.SYNOPSIS
    Sistema de Logging Basico para TFG-AutoDeploy.

.DESCRIPTION
    Modulo para registrar solo los eventos principales:
    - Inicio de procesos
    - Finalizacion exitosa
    - Errores con numero de linea

.EXAMPLE
    Write-BasicLog -Message "Configurando equipo" -Type "INICIO"
    Write-BasicLog -Message "Equipo configurado correctamente" -Type "EXITO"
    Write-BasicLog -Message "Fallo en la configuracion" -Type "ERROR" -LineNumber 45
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
    Escribe mensajes en el archivo de log basico.

.PARAMETER Message
    El mensaje a registrar.

.PARAMETER Type
    Tipo de mensaje: INICIO, EXITO, ERROR
    
.PARAMETER LineNumber
    Numero de linea donde ocurrio el evento (especialmente para errores).
    
.PARAMETER ConsoleOutput
    Si se activa, tambien muestra el log en consola.
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
<#
.SYNOPSIS
    Ejecuta una accion con logging basico automatico.

.PARAMETER Action
    El scriptblock a ejecutar.
    
.PARAMETER Description
    Descripcion de lo que hace la accion.
    
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
<#
.SYNOPSIS
    Verifica si el script se esta ejecutando con permisos de administrador.
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
    Importa un archivo de configuracion con verificacion.

.PARAMETER Path
    Ruta del archivo de configuracion.
    
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

