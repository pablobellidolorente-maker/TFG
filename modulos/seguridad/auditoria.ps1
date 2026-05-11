# ================================
#   FUNCIONES
# ================================

# --- Ver auditorias configuradas ---
function ver-auditorias {
    Clear-Host
    Write-Host "=== ESTADO DE LAS POLITICAS DE AUDITORIA ===" -ForegroundColor Cyan
    
    auditpol.exe /get /category:* 

    Write-Host ""
    Pause   # Evita que desaparezca la pantalla
}

# --- Activar auditorias recomendadas ---
function activar-auditorias {
    Clear-Host
    Write-Host "=== ACTIVAR AUDITORIAS IMPORTANTES ===" -ForegroundColor Cyan

    auditpol.exe /set /subcategory:"Logon" /success:enable /failure:enable
    auditpol.exe /set /subcategory:"Logoff" /success:enable /failure:disable
    auditpol.exe /set /subcategory:"Account Lockout" /success:enable /failure:enable
    auditpol.exe /set /subcategory:"Process Creation" /success:enable /failure:enable
    auditpol.exe /set /subcategory:"Policy Change" /success:enable /failure:enable
    auditpol.exe /set /subcategory:"Privilege Use" /success:enable /failure:disable

    Write-Host "Auditorias activadas correctamente." -ForegroundColor Green
    Pause
}

# --- Desactivar auditorias ---
function desactivar-auditorias {
    Clear-Host
    Write-Host "=== DESACTIVAR AUDITORIAS ===" -ForegroundColor Cyan

    auditpol.exe /set /subcategory:"Logon" /success:disable /failure:disable
    auditpol.exe /set /subcategory:"Logoff" /success:disable /failure:disable
    auditpol.exe /set /subcategory:"Account Lockout" /success:disable /failure:disable
    auditpol.exe /set /subcategory:"Process Creation" /success:disable /failure:disable
    auditpol.exe /set /subcategory:"Policy Change" /success:disable /failure:disable
    auditpol.exe /set /subcategory:"Privilege Use" /success:disable /failure:disable

    Write-Host "Auditorias desactivadas." -ForegroundColor Yellow
    Pause
}

# --- Exportar auditorias a archivo ---
function exportar-auditorias {
    Clear-Host
    Write-Host "=== EXPORTAR CONFIGURACION DE AUDITORIA ===" -ForegroundColor Cyan

    $ruta = Read-Host "Introduce la ruta donde guardar el archivo (ej: C:\auditoria.txt)"

    # Si el archivo NO existe, lo crea automáticamente
    if (-not (Test-Path $ruta)) {
        New-Item -ItemType File -Path $ruta -Force | Out-Null
        Write-Host "Archivo creado: $ruta" -ForegroundColor Yellow
    }

    auditpol.exe /get /category:* > $ruta

    Write-Host "Auditorias exportadas correctamente a: $ruta" -ForegroundColor Green
    Pause
}

# ================================
#   MENU PRINCIPAL
# ================================
do {
    Clear-Host
    Write-Host "===== AUDITORIA DEL SISTEMA =====" -ForegroundColor Cyan
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
