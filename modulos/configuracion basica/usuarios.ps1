
Write-Host "========= GESTION DE USUARIOS Y GRUPOS ========="

#------------------------------------------------------------------------------
# CREAR USUARIO
function Crear-Usuario {

    Write-Host ""
    Write-Host "--- Crear Usuario ---"

    $nombre = Read-Host "Introduzca el nombre del usuario"

    if ([string]::IsNullOrWhiteSpace($nombre)) {
        Write-Host "ERROR: El nombre no puede estar vacio" -ForegroundColor Red
        return
    }

    if (Get-LocalUser -Name $nombre -ErrorAction SilentlyContinue) {
        Write-Host "ERROR: El usuario ya existe" -ForegroundColor Red
        return
    }

    $descripcion = Read-Host "Descripcion del usuario (puede dejarse en blanco)"

    # Pedir contrasena (comparacion correcta)
    do {
        $p1 = Read-Host "Introduzca la contrasena"
        $p2 = Read-Host "Repita la contrasena"

        if ($p1 -ne $p2) {
            Write-Host "ERROR: Las contrasenas no coinciden" -ForegroundColor Red
        }

    } while ($p1 -ne $p2)

    # Convertir a SecureString
    $securePass = ConvertTo-SecureString $p1 -AsPlainText -Force

    New-LocalUser -Name $nombre -Password $securePass -Description $descripcion
    Write-Host "Usuario '$nombre' creado correctamente" -ForegroundColor Green
}

#------------------------------------------------------------------------------
# CREAR GRUPO
function Crear-Grupo {

    Write-Host ""
    Write-Host "--- Crear Grupo ---"

    $grupo = Read-Host "Introduzca el nombre del grupo"

    if ([string]::IsNullOrWhiteSpace($grupo)) {
        Write-Host "ERROR: El nombre no puede estar vacio" -ForegroundColor Red
        return
    }

    if (Get-LocalGroup -Name $grupo -ErrorAction SilentlyContinue) {
        Write-Host "ERROR: El grupo ya existe" -ForegroundColor Red
        return
    }

    New-LocalGroup -Name $grupo
    Write-Host "Grupo '$grupo' creado correctamente" -ForegroundColor Green
}

#------------------------------------------------------------------------------
# ANADIR USUARIO A GRUPO
function Anadir-Usuario-Grupo {

    Write-Host ""
    Write-Host "--- Anadir usuario a grupo ---"

    $usuario = Read-Host "Nombre del usuario"
    $grupo = Read-Host "Nombre del grupo"

    if (-not (Get-LocalUser -Name $usuario -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: El usuario no existe" -ForegroundColor Red
        return
    }

    if (-not (Get-LocalGroup -Name $grupo -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: El grupo no existe" -ForegroundColor Red
        return
    }

    Add-LocalGroupMember -Group $grupo -Member $usuario -ErrorAction Stop
    Write-Host "Usuario anadido correctamente" -ForegroundColor Green
}

#------------------------------------------------------------------------------
# VER USUARIOS
function Ver-Usuarios {
    Write-Host ""
    Write-Host "Usuarios disponibles:"
    Get-LocalUser | Format-Table Name, Enabled, Description
}

#------------------------------------------------------------------------------
# VER GRUPOS
function Ver-Grupos {
    Write-Host ""
    Write-Host "Grupos disponibles:"
    Get-LocalGroup | Format-Table Name
}

#------------------------------------------------------------------------------
# MENU PRINCIPAL
do {

    Write-Host ""
    Write-Host "Seleccione una opcion"
    Write-Host "1) Crear un usuario"
    Write-Host "2) Crear un grupo"
    Write-Host "3) Anadir un usuario a un grupo existente"
    Write-Host "4) Ver usuarios existentes"
    Write-Host "5) Ver grupos existentes"
    Write-Host "6) Salir" -ForegroundColor Cyan

    $opcion = Read-Host "Opcion"

    switch ($opcion) {
        "1" { Crear-Usuario }
        "2" { Crear-Grupo }
        "3" { Anadir-Usuario-Grupo }
        "4" { Ver-Usuarios }
        "5" { Ver-Grupos }
        "6" { Write-Host "Saliendo del menu..." }
        default { Write-Host "ERROR: Opcion no valida" -ForegroundColor Red }
    }

} while ($opcion -ne "6")
