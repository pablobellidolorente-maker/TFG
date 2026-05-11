##Aqui pondria yo todo lo de ajustar la hora, idioma, teclado etc


<#ORDEN DE EJECUCION OPTIMA DE LOS SCRIPTS

1.estructura.ps1

2.usuarios.ps1

3.permisos.ps1

4.hostname.ps1

5.red.ps1

6.sistema.ps1
#>


Write-Host "--------------INICIANDO CONFIGURACION BASICA--------------"

#======================================================
# 1. ESTRUCTURA CARPETAS

Write-Host "`nEjecutando esctructura_carpetas.ps1"
& "$PSScriptRoot\estructura_carpetas.ps1"

#==============================================================
# 2. USUARIOS

Write-Host "`nEjecutando usuarios.ps1"
& "$PSScriptRoot\usuarios.ps1"

#===============================================================
# 3. PERMISOS

Write-Host "`nEjecutando permisos.ps1"
& "$PSScriptRoot\permisos.ps1"

#================================================================
# 4. HOSTNAME

Write-Host "`nEjecutando hostname.ps1"
& "$PSScriptRoot\hostname.ps1"

#=======================================================================
# 5. RED

Write-Host "`nEjecutando red.ps1"
& "$PSScriptRoot\red.ps1"

#==============================================================
# 6. SISTEMA
Write-Host "`nEjecutando sistema.ps1"
& "$PSScriptRoot\sistema.ps1"

Write-Host "`n================= CONFIGURACION BASICA COMPLETADA =================" -ForegroundColor Green

