
Write-Host "========= GESTIÓN DE USUARIOS Y GRUPOS ========="

#Declaramos funciones para que así se las pueda llamar desde el menu interactivo creado abajo del todo


#------------------------------------------------------------------------------
#CREAR USUARIO

function Crear-Usuario {
    
    Write-Host " "
    Write-Host "--- Crear Usuario ---"

    $nombre = Read-Host "Introduzca el nombre del usuario"

    #Comprobacion de nombre no en blanco

    if ([string]::IsNullOrWhiteSpace($nombre)) {
        Write-Host "ERROR: El nombre no puede estar vacío" -ForegroundColor Red
        return
}

#Comprobacion de si el nombre existe

if (Get-LocalUser -Name $nombre -ErrorAction SilentlyContinue){
    Write-Host "ERROR: El usuario ya existe"  -ForegroundColor Red
    return
    }
}

#Descripcion para el usuario (no es obligatoria)

$descripcion = Read-Host "Descripción del usuario (puede dejarse en blanco)"

#Pedir contraseña

do {
    $pass1 = Read-Host "Introduzca la contraseña" -AsSecureString
    $pass2 = Read-Host "Repita la contraseña" -AsSecureString

    # Convertimos ambos SecureString a un formato comparable
    $hash1 = $pass1 | ConvertFrom-SecureString
    $hash2 = $pass2 | ConvertFrom-SecureString

    if ($hash1 -ne $hash2) {
        Write-Host "ERROR: Las contraseñas no coinciden." -ForegroundColor Red
    }

} while ($hash1 -ne $hash2)


#Al llegar aquí tenemos ya el nombre y las credenciales del usuario, ahora con esos datos en la variable, creamos el usuario

New-LocalUser -Name $nombre -Password $pass1 -Description $descripcion
Write-Host "Usuario '$nombre' creado correctamente"

}

#---------------------------------------------------------------------------
#CREAR GRUPO

function Crear-Grupo {

    Write-Host " "
    Write-Host "--- Crear Grupo ---"

    $grupo = Read-Host "Introduzca el nombre del grupo"

        #Comprobacion de nombre no en blanco

    if ([string]::IsNullOrWhiteSpace($grupo)) {
        Write-Host "ERROR: El nombre no puede estar vacío."  -ForegroundColor Red
        return
    }

        #Comprobacion de si el nombre existe

    if (Get-LocalGroup -Name $grupo -ErrorAction SilentlyContinue){
        Write-Host "ERROR: El grupo '$grupo' ya existe"  -ForegroundColor Red
        return    
    }
    
        #AQUI SE CREA YA EL GRUPO

    New-LocalGroup -Name $grupo
    Write-Host "Grupo '$grupo' creado correctamente"
}

#--------------------------------------------------------------------------
#AÑADIR USUARIOS A UN GRUPO

function Anadir-Usuario-Grupo {
    Write-Host " "
    Write-Host "--- Añadir usuario a grupo ---"


    Write-Host " "
    
    $usuario = Read-Host "Nombre del usuario"
    $grupo = Read-Host "Nombre del grupo"

    #Al igual que antes, validamos si el usuario y grupo existen

     if (-not (Get-LocalUser -Name $usuario -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: El usuario '$usuario' no existe."  -ForegroundColor Red
        return
    }

    if (-not (Get-LocalGroup -Name $grupo -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: El grupo '$grupo' no existe."  -ForegroundColor Red
        return
    }

    #Una vez se han realizado todas las comprobaciones, se añade el usuario al grupo

    Add-LocalGroupMember -Group $grupo -Member $usuario -ErrorAction Stop
    Write-Host "Usuario '$usuario' añadido al grupo '$grupo'."

}

#--------------------------------------------------------------------------------
#FUNCION PARA VER LOS USUARIOS EXISTENTES

function Ver-Usuarios {
        #Las siguientes lineas hacen que el host vea que usuarios existen

    Write-Host " "
    
    Write-Host "Usuarios disponibles:"
    
    Get-LocalUser | Format-Table Name, Enabled, Description

}

#--------------------------------------------------------------------------------
#FUNCION PARA VER LOS GRUPOS EXISTENTES

function Ver-Grupos {
        #Las siguientes lineas hacen que el host vea que usuarios existen

    Write-Host " "
    
    Write-Host "Grupos disponibles:"
    
    Get-LocalGroup | Format-Table Name
}

#------------------------------------------------------------------------------------


#=========== MENÚ QUE VERÁ EL USUARIO ============

#Creamos un bucle para que siempre se vuelva al menu a no ser que se especifique "salir"

do {
    
    Write-Host "`nSeleccione una opción"
    Write-Host "1) Crear un usuario"
    Write-Host "2) Crear un grupo"
    Write-Host "3) Añadir un usuario a un grupo existente"
    Write-Host "4) Ver usuarios existentes"
    Write-Host "5) Ver grupos existentes"
    Write-Host "6) Salir"  -ForegroundColor Cyan

    #variable de la respuesta

    $opcion = Read-Host "Opción"

    #Creamos un switch, que permite que un mismo input pueda tener varios valores (las opciones)

    switch ($opcion) {
        "1" { Crear-Usuario }
        "2" { Crear-Grupo }
        "3" { Anadir-Usuario-Grupo }
        "4" { Ver-Usuarios }
        "5" { Ver-Grupos }
        "6" { Write-Host "Saliendo del menu de usuarios"}

        default { Write-Host "ERROR: Recuerde, debe de elegir un valor entre (1-6)"  -ForegroundColor Red }    
    }

} while ($opcion -ne "6")
