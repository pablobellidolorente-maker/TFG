do {
Write-Host ""
Write-Host "========BIENVENIDO========"
Write-Host ""
Write-Host "Ha seleccionado la configuracion completa, por favor, elija el departamento para el que se va a utilizar 
            su equipo"
Write-Host ""
Write-Host "1) Departamento de base de datos" -ForegroundColor Magenta
Write-Host ""
Write-Host "2) Departamento de administradores de sistema" -ForegroundColor Red
Write-Host ""
Write-Host "3) Departamento de redes" -ForegroundColor Cyan 
Write-Host ""
Write-Host "4) Departamento comercial" -ForegroundColor Green
Write-Host ""
Write-Host "5) Salir"

$respuesta = Read-Host

switch ($respuesta) {
    "1" {Write-Host "rutascript1 apps y secc base de datos" -ForegroundColor Magenta}
    "2" {Write-Host "rutascript2 (apps y secc sistemas)" -ForegroundColor Red}
    "3" {Write-Host "rutascript3 (apps y secc redes)" -ForegroundColor Cyan}
    "4" {Write-Host "rutascript4 (apps y secc ventas)" -ForegroundColor Green}
    "5" {Write-Host "Saliendo, gracias..."}
    default {Write-Host "Opcion no valida, introduzca los parametros: 1 , 2 , 3 , 4 o 5"}

}

}while ($respuesta -ne "5")

