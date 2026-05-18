# ============================
#   IMPORTAR MODULOS DE LOGGING
# ============================

. ".\modulos\logging-basico.ps1"
. ".\modulos\logging-detallado.ps1"

Write-Host "============ CONFIGURACION DE PERMISOS DEL SISTEMA ============"

#=====================================================
# FUNCION PARA EL EXECUTION POLICY

function Configurar-ExPolicy {

    Write-Host "`n --- Cambiar Execution Policy ---"
    Write-Host "1) Restricted"
    Write-Host "2) RemoteSigned"
    Write-Host "3) Unrestricted"
    Write-Host "4) Bypass"

    $opcion = Read-Host "Seleccione una opcion"

    switch ($opcion) {

        "1" {
            Set-ExecutionPolicy Restricted -Scope CurrentUser -Force
            Set-ExecutionPolicy Restricted -Scope LocalMachine -Force
            Set-ExecutionPolicy Restricted -Scope Process -Force
        }

        "2" {
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
            Set-ExecutionPolicy RemoteSigned -Scope Process -Force
        }

        "3" {
            Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
            Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force
            Set-ExecutionPolicy Unrestricted -Scope Process -Force
        }

        "4" {
            Set-ExecutionPolicy Bypass -Scope CurrentUser -Force
            Set-ExecutionPolicy Bypass -Scope LocalMachine -Force
            Set-ExecutionPolicy Bypass -Scope Process -Force
        }

        default {
            Write-Host "Opcion no valida"
            return
        }
    }

    Write-Host "ExecutionPolicy cambiada en todos los scopes disponibles."
}


#=====================================================
# FUNCION CONFIGURAR UAC

function Configurar-UAC {

    Write-Host "`n--- Configurar UAC (Control de Cuentas de Usuario) ---"
    Write-Host "1) Maxima seguridad (notificar siempre)"
    Write-Host "2) Nivel por defecto"
    Write-Host "3) Nivel bajo (menos avisos)"
    Write-Host "4) Desactivar UAC (no recomendado)"

    $opcion = Read-Host "Seleccione una opcion"

    switch ($opcion) {
        "1" {
            Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System `
                -Name "ConsentPromptBehaviorAdmin" -Value 2
        }
        "2" {
            Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System `
                -Name "ConsentPromptBehaviorAdmin" -Value 5
        }
        "3" {
            Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System `
                -Name "ConsentPromptBehaviorAdmin" -Value 0
        }
        "4" {
            Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System `
                -Name "EnableLUA" -Value 0
        }
        default { Write-Host "Opcion no valida" }
    }

    Write-Host "UAC configurado correctamente" -ForegroundColor Green
}

#=====================================================
# VER USUARIOS Y PRIVILEGIOS

function VerUsuarios  {

    $usuarios = Get-LocalUser
    $admins = Get-LocalGroupMember -Group "Administradores" -ErrorAction SilentlyContinue

    # Extraer solo el nombre sin el prefijo del equipo
    $adminNames = $admins | ForEach-Object { $_.Name.Split("\")[-1] }

    foreach ($user in $usuarios) {

        if ($adminNames -contains $user.Name) {
            $rol = "Administrador"
        }
        else {
            $rol = "Usuario normal"
        }

        Write-Host "Usuario: $($user.Name)"
        Write-Host "  Estado: $($user.Enabled)"
        Write-Host "  Privilegios: $rol"
        Write-Host ""
    }
}


#=====================================================
# GESTIONAR PRIVILEGIOS

function Gestionar-Privilegios {

    Write-Host "`n--- Gestion de privilegios de usuarios ---"
    Write-Host "1) Anadir usuario al grupo Administradores"
    Write-Host "2) Quitar usuario del grupo Administradores"
    Write-Host "3) Ver usuarios y sus privilegios"

    $opcion = Read-Host "Seleccione una opcion"

    switch ($opcion) {
        "1" { 
            $usuario = Read-Host "Nombre del usuario"

            if (-not (Get-LocalUser -Name $usuario -ErrorAction SilentlyContinue)) {
                Write-Host "ERROR: El usuario '$usuario' no existe." -ForegroundColor Red
                return
            }

            Add-LocalGroupMember -Group "Administradores" -Member $usuario
            Write-Host "Usuario anadido."
        }

        "2" { 
            $usuario = Read-Host "Nombre del usuario"

            if (-not (Get-LocalUser -Name $usuario -ErrorAction SilentlyContinue)) {
                Write-Host "ERROR: El usuario '$usuario' no existe." -ForegroundColor Red
                return
            }
            
            Remove-LocalGroupMember -Group "Administradores" -Member $usuario
            Write-Host "Usuario eliminado."
        }

        "3" { VerUsuarios }

        default { Write-Host "ERROR: Opcion no valida." -ForegroundColor Red }
    }
}

#=====================================================
# GESTIONAR USUARIO ADMINISTRADOR (ROOT)

function Gestionar-Root {

    Write-Host "`n--- Gestion del usuario Administrador ---"
    Write-Host "1) Activar Administrador"
    Write-Host "2) Desactivar Administrador"

    $opcion = Read-Host "Seleccione una opcion"

    switch ($opcion) {
        "1" { Enable-LocalUser -Name "Administrador"; Write-Host "Administrador (root) Activo" }
        "2" { Disable-LocalUser -Name "Administrador"; Write-Host "Administrador (root) Desactivado" }
        default { Write-Host "Opcion invalida" }
    }
}

#=====================================================
# PERMISOS DE CARPETAS (NTFS)

function Permisos-Carpetas {

    $ruta = Read-Host "Introduzca la ruta completa de la carpeta que quiere gestionar"
    if (-not (Test-Path $ruta)) {
        Write-Host "ERROR: La ruta no existe o no la ha escrito correctamente" -ForegroundColor Red
        return
    }

    Write-Host " 1) Dar control total a los administradores"
    Write-Host " 2) Dar lectura a los usuarios"
    Write-Host " 3) Quitar permisos heredados"
    Write-Host " 4) Listar las carpetas dentro de la ruta"

    $opcion = Read-Host "Seleccione una opcion"

    switch ($opcion) {

        "1" {
            icacls $ruta /grant Administrators:F /T
            Write-Host "Permisos aplicados correctamente" -ForegroundColor Green
        }
        
        "2" {
            icacls $ruta /grant Users:R /T
            Write-Host "Permisos aplicados correctamente" -ForegroundColor Green
        }

        "3" {
            icacls $ruta /inheritance:d
            Write-Host "La herencia ha sido desactivada correctamente" -ForegroundColor Green
        }

        "4" {
            Write-Host "Carpetas dentro de $ruta"
            Get-ChildItem -Path $ruta -Directory | Select-Object Name, FullName
        }

        default {
            Write-Host "Opcion no valida"
        }
    }
}

#=====================================================
# MENU PRINCIPAL

do {
    Write-Host "`nSeleccione una opcion:"
    Write-Host "1) Cambiar ExecutionPolicy"
    Write-Host "2) Configurar UAC"
    Write-Host "3) Activar/Desactivar Administrador"
    Write-Host "4) Gestionar permisos NTFS (carpetas)"
    Write-Host "5) Gestionar privilegios de usuarios"
    Write-Host "6) Salir" -ForegroundColor Cyan

    $opcion = Read-Host "Opcion"

    switch ($opcion) {
        "1" { Configurar-ExPolicy } 
        "2" { Configurar-UAC }
        "3" { Gestionar-Root } 
        "4" { Permisos-Carpetas } 
        "5" { Gestionar-Privilegios } 
        "6" { Write-Host "Saliendo del modulo de permisos..." }
        default { Write-Host "ERROR: Seleccione una opcion valida (1-6)" -ForegroundColor Red }
    }

} while ($opcion -ne "6")
