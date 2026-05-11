
# ================================
#   FUNCIONES
# ================================

# --- Ver auditorías configuradas ---
function ver-auditorias {
    Clear-Host
    Write-Host "=== ESTADO DE LAS POLÍTICAS DE AUDITORÍA ===" -ForegroundColor Cyan
    auditpol.exe /get /category:* 
    Pause
}

# --- Activar auditorías recomendadas ---
function activar-auditorias {
    Clear-Host
    Write-Host "=== ACTIVAR AUDITORÍAS IMPORTANTES ===" -ForegroundColor Cyan

    auditpol /set /subcategory:"Logon" /success:enable /failure:enable
    auditpol /set /subcategory:"Logoff" /success:enable /failure:disable
    auditpol /set /subcategory:"Account Lockout" /success:enable /failure:enable
    auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable
    auditpol /set /subcategory:"Policy Change" /success:enable /failure:enable
    auditpol /set /subcategory:"Privilege Use" /success:enable /failure:disable

    Write-Host "Auditorías activadas correctamente." -ForegroundColor Green
    Pause
}

# --- Desactivar auditorías ---
function desactivar-auditorias {
    Clear-Host
    Write-Host "=== DESACTIVAR AUDITORÍAS ===" -ForegroundColor Cyan

    auditpol /set /subcategory:"Logon" /success:disable /failure:disable
    auditpol /set /subcategory:"Logoff" /success:disable /failure:disable
    auditpol /set /subcategory:"Account Lockout" /success:disable /failure:disable
    auditpol /set /subcategory:"Process Creation" /success:disable /failure:disable
    auditpol /set /subcategory:"Policy Change" /success:disable /failure:disable
    auditpol /set /subcategory:"Privilege Use" /success:disable /failure:disable

    Write-Host "Auditorías desactivadas." -ForegroundColor Yellow
    Pause
}

# --- Exportar auditorías a archivo ---
function exportar-auditorias {
    Clear-Host
    Write-Host "=== EXPORTAR CONFIGURACIÓN DE AUDITORÍA ===" -ForegroundColor Cyan

    $ruta = Read-Host "Introduce la ruta donde guardar el archivo (ej: C:\auditoria.txt)"

    auditpol /get /category:* > $ruta

    Write-Host "Auditorías exportadas correctamente a: $ruta" -ForegroundColor Green
    Pause
}

# ================================
#   MENÚ PRINCIPAL
# ================================
do {
    Clear-Host
    Write-Host "===== AUDITORÍA DEL SISTEMA =====" -ForegroundColor Cyan
    Write-Host "1. Ver auditorías configuradas"
    Write-Host "2. Activar auditorías recomendadas"
    Write-Host "3. Desactivar auditorías"
    Write-Host "4. Exportar auditorías a archivo"
    Write-Host "0. Salir"
    $opcion = Read-Host "Selecciona una opción"

    switch ($opcion) {
        "1" { ver-auditorias }
        "2" { activar-auditorias }
        "3" { desactivar-auditorias }
        "4" { exportar-auditorias }
        "0" { break }
        default { Write-Host "Opción no válida." -ForegroundColor Red; Pause }
    }

} while ($opcion -ne "0")
