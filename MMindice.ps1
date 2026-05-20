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
    Write-Host "Bienvenido al menú de configuración, seleccione una opción:"
    Write-Host ""
    Write-Host "1) Configuración básica del sistema" -ForegroundColor Red
    Write-Host ""
    Write-Host "2) Configuración de instalación de software" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "3) Configuración de seguridad del sistema" -ForegroundColor Green
    Write-Host ""
    Write-Host "4) Salir" -ForegroundColor Cyan

    $respuesta = Read-Host

    switch ($respuesta) {

        "1" {
            & ".\modulos\configuracion basica\Mconf_basica.ps1"
        }

        "2" {
            & ".\modulos\software\Msoftware_P.ps1"
        }

        "3" {
            & ".\modulos\seguridad\Mseguridad.ps1"
        }

        "4" {
            Write-Host "Saliendo, gracias..."
        }

        default {
            Write-Host "ERROR: Opción no válida, introduzca 1, 2, 3 o 4" -ForegroundColor Red
        }
    }

} while ($respuesta -ne "4")
