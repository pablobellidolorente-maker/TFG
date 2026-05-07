
# ================================
#   FUNCIONES
# ================================

# --- Ver auditorias configuradas ---
function ver-auditorias {
    Clear-Host
    Write-Host "=== ESTADO DE LAS POLiTICAS DE AUDITORiA ===" -ForegroundColor Cyan
    auditpol.exe /get /category:* 
    Pause
}

# --- Activar auditorias recomendadas ---
function activar-auditorias {
    Clear-Host
    Write-Host "=== ACTIVAR AUDITORiAS IMPORTANTES ===" -ForegroundColor Cyan

    auditpol /set /subcategory:"Logon" /success:enable /failure:enable
    auditpol /set /subcategory:"Logoff" /success:enable /failure:disable
    auditpol /set /subcategory:"Account Lockout" /success:enable /failure:enable
    auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable
    auditpol /set /subcategory:"Policy Change" /success:enable /failure:enable
    auditpol /set /subcategory:"Privilege Use" /success:enable /failure:disable

    Write-Host "Auditorias activadas correctamente." -ForegroundColor Green
    Pause
}

# --- Desactivar auditorias ---
function desactivar-auditorias {
    Clear-Host
    Write-Host "=== DESACTIVAR AUDITORiAS ===" -ForegroundColor Cyan

    auditpol /set /subcategory:"Logon" /success:disable /failure:disable
    auditpol /set /subcategory:"Logoff" /success:disable /failure:disable
    auditpol /set /subcategory:"Account Lockout" /success:disable /failure:disable
    auditpol /set /subcategory:"Process Creation" /success:disable /failure:disable
    auditpol /set /subcategory:"Policy Change" /success:disable /failure:disable
    auditpol /set /subcategory:"Privilege Use" /success:disable /failure:disable

    Write-Host "Auditorias desactivadas." -ForegroundColor Yellow
    Pause
}

# --- Exportar auditorias a archivo ---
function exportar-auditorias {
    Clear-Host
    Write-Host "=== EXPORTAR CONFIGURACIoN DE AUDITORiA ===" -ForegroundColor Cyan

    $ruta = Read-Host "Introduce la ruta donde guardar el archivo (ej: C:\auditoria.txt)"

    auditpol /get /category:* > $ruta

    Write-Host "Auditorias exportadas correctamente a: $ruta" -ForegroundColor Green
    Pause
}

# ================================
#   MENu PRINCIPAL
# ================================
do {
    Clear-Host
    Write-Host "===== AUDITORiA DEL SISTEMA =====" -ForegroundColor Cyan
    Write-Host "1. Ver auditorias configuradas"
    Write-Host "2. Activar auditorias recomendadas"
    Write-Host "3. Desactivar auditorias"
    Write-Host "4. Exportar auditorias a archivo"
    Write-Host "0. Salir"
    $opcion = Read-Host "Selecciona una opcion"

    switch ($opcion) {
        "1" { ver-auditorias }
        "2" { activar-auditorias }
        "3" { desactivar-auditorias }
        "4" { exportar-auditorias }
        "0" { break }
        default { Write-Host "Opcion no valida." -ForegroundColor Red; Pause }
    }

} while ($opcion -ne "0")
