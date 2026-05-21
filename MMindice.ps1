<#Codigo basico del menu, en el que se le dan las opciones a elegir al usuario, que,
llamaran a los demas scripts para ejecutar la configuracion elegida#>

# powershell -ExecutionPolicy Bypass -File .\MMindice.ps1


#============================"
#      MENU PRINCIPAL"
#============================"

do {
    Write-Host ""
    Write-Host "========BIENVENIDO========"
    Write-Host ""
    Write-Host "Bienvenido al menu de configuracion, seleccione una opcion:"
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
            & ".\modulos\configuracion basica\Mconf_basica.ps1"
        }

        "2" {
            & ".\modulos\software\Msoftware.ps1"
        }

        "3" {
            & ".\modulos\seguridad\Mseguridad.ps1"
        }

        "4" {
            Write-Host "Saliendo, gracias..."
        }

        default {
            Write-Host "ERROR: Opcion no valida, introduzca 1, 2, 3 o 4" -ForegroundColor Red
        }
    }

} while ($respuesta -ne "4")
