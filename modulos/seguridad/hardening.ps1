# ================================
#   hardening.ps1
#   Módulo de seguridad: Hardening del sistema
#   Requisitos: Ejecutar como administrador
# ================================

# --- Comprobación de permisos ---
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script debe ejecutarse como administrador." -ForegroundColor Red
    exit
}

# ================================
#   FUNCIONES
# ================================

# --- Deshabilitar servicios inseguros ---
function deshabilitar-servicios {
    Clear-Host
    Write-Host "=== DESHABILITANDO SERVICIOS INSEGUROS ===" -ForegroundColor Cyan

    # SMBv1 (Servicio de comparticion de archivos de los años 90 sin cifrado integridad ni nada , y por lo visto muy vulnerable, se deshabilita)
    Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
    Write-Host "SMBv1 deshabilitado." -ForegroundColor Green

    # Telnet (Obsoleto e inseguro)
    Set-Service -Name TlntSvr -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "Telnet deshabilitado." -ForegroundColor Green

    # Remote Registry (Permite modificar registro de windows de forma remota, se puedn cambiar configuraciones criticas)
    Set-Service -Name RemoteRegistry -StartupType Disabled
    Write-Host "Remote Registry deshabilitado." -ForegroundColor Green

    Pause
}

# --- Configurar políticas de contraseñas --- (politicas basicas basadas en los estandares recomendados por micrososft)
function politicas-contraseña {
    Clear-Host
    Write-Host "=== CONFIGURANDO POLÍTICAS DE CONTRASEÑA ===" -ForegroundColor Cyan

    secedit /export /cfg C:\secpol.cfg | Out-Null

    (Get-Content C:\secpol.cfg).Replace("MinimumPasswordLength = 0", "MinimumPasswordLength = 8") |
        Set-Content C:\secpol.cfg

    (Get-Content C:\secpol.cfg).Replace("PasswordHistorySize = 0", "PasswordHistorySize = 5") |
        Set-Content C:\secpol.cfg

    (Get-Content C:\secpol.cfg).Replace("MaximumPasswordAge = 42", "MaximumPasswordAge = 30") |
        Set-Content C:\secpol.cfg

    secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /quiet

    Write-Host "Políticas de contraseña aplicadas." -ForegroundColor Green
    Pause
}

# --- Deshabilitar protocolos inseguros ---
function deshabilitar-protocolos {
    Clear-Host
    Write-Host "=== DESHABILITANDO PROTOCOLOS INSEGUROS ===" -ForegroundColor Cyan

    # Deshabilitar LM y NTLMv1 (protocolo de autenticacion antiguo de windows)
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name LmCompatibilityLevel -Value 5 -PropertyType DWord -Force
    Write-Host "LM y NTLMv1 deshabilitados." -ForegroundColor Green

    # Deshabilitar TLS 1.0 y 1.1 (versiones antiguas del TLS)
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name Enabled -Value 0 -PropertyType DWord -Force

    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name Enabled -Value 0 -PropertyType DWord -Force

    Write-Host "TLS 1.0 y 1.1 deshabilitados." -ForegroundColor Green
    Pause
}

# --- Configurar RDP ---
function configurar-rdp {
    Clear-Host
    Write-Host "=== CONFIGURACIÓN DE RDP ===" -ForegroundColor Cyan

    Write-Host "1) Deshabilitar RDP"
    Write-Host "2) Habilitar RDP con seguridad reforzada"
    Write-Host "3) Volver"

    $op = Read-Host "Opción"

    switch ($op) {
        "1" {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -Value 1
            Write-Host "RDP deshabilitado." -ForegroundColor Yellow
        }
        "2" {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -Value 0
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name UserAuthentication -Value 1
            Write-Host "RDP habilitado con NLA." -ForegroundColor Green
        }
        default { Write-Host "Volviendo..." }
    }

    Pause
}

# --- Deshabilitar AutoRun --- (Hace que se ejecute un USB o disco sin interaccion del usuario)
function deshabilitar-autorun {
    Clear-Host
    Write-Host "=== DESHABILITANDO AUTORUN ===" -ForegroundColor Cyan

    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
        -Name NoDriveTypeAutoRun -Value 255 -PropertyType DWord -Force

    Write-Host "AutoRun deshabilitado." -ForegroundColor Green
    Pause
}

# ================================
#   MENÚ PRINCIPAL
# ================================
do {
    Clear-Host
    Write-Host "===== HARDENING DEL SISTEMA =====" -ForegroundColor Cyan
    Write-Host "1. Deshabilitar servicios inseguros"
    Write-Host "2. Configurar políticas de contraseña"
    Write-Host "3. Deshabilitar protocolos inseguros"
    Write-Host "4. Configurar RDP"
    Write-Host "5. Deshabilitar AutoRun"
    Write-Host "0. Salir"

    $opcion = Read-Host "Selecciona una opción"

    switch ($opcion) {
        "1" { deshabilitar-servicios }
        "2" { politicas-contraseña }
        "3" { deshabilitar-protocolos }
        "4" { configurar-rdp }
        "5" { deshabilitar-autorun }
        "0" { break }
        default { Write-Host "Opción no válida." -ForegroundColor Red; Pause }
    }

} while ($opcion -ne "0")
