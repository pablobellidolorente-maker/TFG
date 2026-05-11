
#=================================================================

#FUNCIONES

#==================================================================

#VARIABLES QUE SE VAN A USAR CONSTANTEMENTE LOGS Y LA RUTA DE LOS ARCHIVOS TXT QUE CONTIENEN LOS ID DE LAS APPS PARA WINGET



$listaPath = "$PSScriptRoot\listas_software\"
$logPath = "$PSScriptRoot\logs\software.log"

if (!(Test-Path ".\logs")) { New-Item -ItemType Directory -Path ".\logs" | Out-Null }

# --- Instalar software por departamento ---

#ATENCION AL TOCAR ESTA FUNCION (TIENE CHICHA) EXPLICACION:

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

    #Determinamos dentro de la funcion que la opcion que ellos eligen sea 1-0 sea a su vez una variable que varia de entre todos los archivos txt que tenemos, estos, se usaran posteriormente como array

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

    #Determinamos que $ruta, es la union del path de donde tenemos los arrays en .txt y el nombre del archivo, por ello es importante que existan estas dos variables si o si

    $ruta = "$listaPath$archivo"

    if (!(Test-Path $ruta)) {
        Write-Host "ERROR: No se encontro la lista $archivo" -ForegroundColor Red
        
        return
    }

    #Aqui es donde se determina que cada una de las lineas es un programa y lo utilizamos con los id oficiales de las app que tiene el repositorio oficial de windows

    $programas = Get-Content $ruta

    foreach ($p in $programas) {
        Write-Host "`nInstalando: $p" -ForegroundColor Yellow

        #comando de powershell predeterminado para instalar algo y aceptar automaticamente

        winget install $p --silent --accept-source-agreements --accept-package-agreements | Tee-Object -Append -FilePath $logPath
    }

    Write-Host "`nInstalacion completada para el departamento seleccionado." -ForegroundColor Green
    Pause
}

#=====================================================================================

# --- Instalacion personalizada ---

#Se permite instalar cualquier app dentro de las que tiene windows en su repositorio oficial, pero presentamos los mas comunes


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

    winget install $id --silent --accept-source-agreements --accept-package-agreements | `
        Tee-Object -Append -FilePath $logPath

    Write-Host "`nInstalacion completada." -ForegroundColor Green
}

#====================================================================================================

# --- Actualizar software ---

function actualizar-software {
    Clear-Host
    Write-Host "=== ACTUALIZANDO SOFTWARE ===" -ForegroundColor Cyan

    winget upgrade --all --silent --accept-source-agreements --accept-package-agreements | Tee-Object -Append -FilePath $logPath

    Write-Host "Actualizacion completada." -ForegroundColor Green

}

#=============================================================================================

# --- Desinstalar software ---

function desinstalar-software {
    Clear-Host
    Write-Host "=== DESINSTALAR SOFTWARE ===" -ForegroundColor Cyan

    $id = Read-Host "Introduce el ID de Winget del programa a desinstalar"

    winget uninstall $id | Tee-Object -Append -FilePath $logPath

    Write-Host "Desinstalacion completada." -ForegroundColor Green
    
}

#=============================================================================

# --- Listar software instalado ---

function listar-software {
    Clear-Host
    Write-Host "=== SOFTWARE INSTALADO ===" -ForegroundColor Cyan

    winget list
    
}


#===================================================================

# --- Ver logs ---

function ver-logs {
    Clear-Host
    Write-Host "=== LOGS DE SOFTWARE ===" -ForegroundColor Cyan

    if (Test-Path $logPath) {
        Get-Content $logPath
    } else {
        Write-Host "No hay logs disponibles." -ForegroundColor Yellow
    }
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