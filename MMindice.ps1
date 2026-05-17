<#Codigo basico del menu, en el que se le dan las opciones a elegir al usuario, que,
llamaran a los demas scripts para ejecutar la configuracion elegida#>


#Vamos a tener que ejecutar este script usando esto:

# powershell -ExecutionPolicy Bypass -File .\MMindice.ps1 ya que si no, las politicas de windows no dejan ejecutar scripts


#=======================================================================================
# FUNCION PARA COMPROBAR PERMISOS DE ADMINISTRADOR
#=======================================================================================

function Comprobar-Admin {
    
    $usuario = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($usuario)
    
    if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host ""
        Write-Host "========== ERROR ==========" -ForegroundColor Red
        Write-Host ""
        Write-Host "Este script requiere permisos de ADMINISTRADOR para funcionar correctamente." -ForegroundColor Red
        Write-Host ""
        Write-Host "Por favor, ejecute PowerShell como Administrador:" -ForegroundColor Yellow
        Write-Host "1. Click derecho en PowerShell" -ForegroundColor Cyan
        Write-Host "2. Seleccione 'Ejecutar como administrador'" -ForegroundColor Cyan
        Write-Host "3. Acepte el aviso de UAC" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "==========================" -ForegroundColor Red
        Write-Host ""
        Pause
        exit
    }
}

#=======================================================================================
# COMPROBAR PERMISOS AL INICIAR
#=======================================================================================

Comprobar-Admin

Write-Host ""
Write-Host "Permisos de administrador verificados correctamente." -ForegroundColor Green
Write-Host ""


#=======================================================================================
# MENU PRINCIPAL
#=======================================================================================

do {
    Write-Host ""
    Write-Host "========BIENVENIDO========"
    Write-Host ""
    Write-Host "Bienvenido al menu de configuracion, por favor, seleccione la opcion para configurar su equipo:"
    Write-Host ""
    Write-Host "1) Configuracion completa del equipo" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "2) Configuracion basica del sistema" -ForegroundColor Red
    Write-Host ""
    Write-Host "3) Configuracion de instalacion de software" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "4) Configuracion de seguridad del sistema" -ForegroundColor Green
    Write-Host ""
    Write-Host "5) Salir" -ForegroundColor Cyan
    
    $respuesta = Read-Host
    
    switch ($respuesta) {
        "1" { & ".\modulos\opciones_dpt.ps1"
                 Write-Host "rutascript1"}
        
        "2" { & ".\modulos\configuracion basica\Mconf_basica.ps1"
            Write-Host "rutascript2"}
        
        "3" { & ".\modulos\software\Msoftware.ps1"
            Write-Host "rutascript3"}
        
        "4" { & ".\modulos\seguridad\Mseguridad.ps1"
            Write-Host "rutascript4"}
        
        "5" {Write-Host "Saliendo, gracias..."}
        default {Write-Host "ERROR: Opcion no valida, introduzca los parametros: 1 , 2 , 3 , 4 o 5" -ForegroundColor Red }
    
    }
    
}while ($respuesta -ne "5")

