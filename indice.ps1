<#Código básico del menu, en el que se le dan las opciones a elegir al usuario, que,
llamaran a los demas scripts para ejecutar la configuracion elegida#>

do {
Write-Host ""
Write-Host "========BIENVENIDO========"
Write-Host ""
Write-Host "Bienvenido al menú de configuración, por favor, seleccione la opción para configurar su equipo"
Write-Host ""
Write-Host "1) Configuración completa del equipo" -ForegroundColor Magenta
Write-Host ""
Write-Host "2) Configuración básica del sistema" -ForegroundColor Red
Write-Host ""
Write-Host "3) Configuración de instalación de software" -ForegroundColor Cyan
Write-Host ""
Write-Host "4) Configuración de seguridad del sistema" -ForegroundColor Green
Write-Host ""
Write-Host "5) Salir"

$respuesta = Read-Host

switch ($respuesta) {
    "1" { .\opciones_dpt.ps1
             Write-Host "rutascript1"}
    
    "2" {Write-Host "rutascript2"}
    
    "3" {Write-Host "rutascript3"}
    
    "4" {Write-Host "rutascript4"}
    
    "5" {Write-Host "Saliendo, gracias..."}
    default {Write-Host "Opción no válida, introduzca los parámetros: 1 , 2 , 3 , 4 o 5"}

}

}while ($respuesta -ne "5")

