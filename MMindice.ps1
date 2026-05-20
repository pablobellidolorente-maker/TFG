<#Codigo basico del menu, en el que se le dan las opciones a elegir al usuario, que,
llamaran a los demas scripts para ejecutar la configuracion elegida#>

# powershell -ExecutionPolicy Bypass -File .\MMindice.ps1

Write-DetailedLog -Message "Iniciando menu principal"

# ============================
#   MENU PRINCIPAL
# ============================

do {
    Write-Host ""
    Write-Host "========BIENVENIDO========"
    Write-Host ""
    Write-Host "Bienvenido al menu de configuracion, por favor, seleccione la opcion para configurar su equipo:"
    Write-Host ""
    Write-Host "1) Configuracion basica del sistema" -ForegroundColor Red
    Write-Host ""
    Write-Host "2) Configuracion de instalacion de software" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "3) Configuracion de seguridad del sistema" -ForegroundColor Green
    Write-Host ""
    Write-Host "4) Salir" -ForegroundColor Cyan
    
    $respuesta = Read-Host
    
    switch ($respuesta) {
        
        "1" { 
            Write-BasicLog -Message "Usuario selecciono: Configuracion basica del sistema" -Type "INICIO" -ConsoleOutput
            Write-DetailedLog -Message "Usuario selecciono: Configuracion basica del sistema" -ConsoleOutput
            & ".\modulos\configuracion basica\Mconf_basica.ps1"
            Write-BasicLog -Message "Finalizo: Configuracion basica del sistema" -Type "EXITO" -ConsoleOutput
            Write-DetailedLog -Message "Finalizo: Configuracion basica del sistema" -ConsoleOutput
        }
        
        "2" { 
            Write-BasicLog -Message "Usuario selecciono: Configuracion de instalacion de software" -Type "INICIO" -ConsoleOutput
            Write-DetailedLog -Message "Usuario selecciono: Configuracion de instalacion de software" -ConsoleOutput
            & ".\modulos\software\Msoftware.ps1"
            Write-BasicLog -Message "Finalizo: Configuracion de instalacion de software" -Type "EXITO" -ConsoleOutput
            Write-DetailedLog -Message "Finalizo: Configuracion de instalacion de software" -ConsoleOutput
        }
        
        "3" { 
            Write-BasicLog -Message "Usuario selecciono: Configuracion de seguridad del sistema" -Type "INICIO" -ConsoleOutput
            Write-DetailedLog -Message "Usuario selecciono: Configuracion de seguridad del sistema" -ConsoleOutput
            & ".\modulos\seguridad\Mseguridad.ps1"
            Write-BasicLog -Message "Finalizo: Configuracion de seguridad del sistema" -Type "EXITO" -ConsoleOutput
            Write-DetailedLog -Message "Finalizo: Configuracion de seguridad del sistema" -ConsoleOutput
        }
        
        "4" {
            Write-BasicLog -Message "Usuario selecciono: Salir del programa" -Type "EXIT" -ConsoleOutput
            Write-DetailedLog -Message "Usuario selecciono: Salir del programa" -ConsoleOutput
            Write-Host "Saliendo, gracias..."
        }
        
        default {
            Write-BasicLog -Message "Usuario ingreso opcion no valida: $respuesta" -Type "ERROR" -ConsoleOutput
            Write-DetailedLog -Message "Usuario ingreso opcion no valida: $respuesta" -ConsoleOutput
            Write-Host "ERROR: Opcion no valida, introduzca los parametros: 1 , 2 , 3 , 4 o 5" -ForegroundColor Red 
        }
    
    }
    
}while ($respuesta -ne "4")
