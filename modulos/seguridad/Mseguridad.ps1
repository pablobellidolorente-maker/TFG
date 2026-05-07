##Aqui lo mismo, las politicas de seguridad de cada equipo dependiendo de sus necesidades


<#ORDEN OPTIMO DE EJECUCION

1) FIREWALL.ps1

2) DEFENDER.ps1

3) AUDITORIA.ps1

4) HARDENING.ps1
#>



Write-Host "--------------INICIANDO CONFIGURACION SEGURIDAD--------------"

#======================================================
# 1.FIREWALL

Write-Host "`nEjecutando firewall.ps1"
& "$PSScriptRoot\firewall.ps1"

#==============================================================
# 2. DEFENDER

Write-Host "`nEjecutando defender.ps1"
& "$PSScriptRoot\defender.ps1"

#===============================================================
# 3. AUDITORIA

Write-Host "`nEjecutando auditoria.ps1"
& "$PSScriptRoot\auditoria.ps1"

#================================================================
# 4. HARDENING

Write-Host "`nEjecutando hardening.ps1"
& "$PSScriptRoot\hardening.ps1"



Write-Host "`n================= CONFIGURACION SEGURIDAD COMPLETADA =================" -ForegroundColor Green

