Write-Host "============ CONFIGURACIÓN DE PERMISOS DEL SISTEMA ============"

##=====================================================

#FUNCION PARA EL EXECUTION POLICY (PERMITE EJECUTAR SCRIPTS ADEMAS DE OTRAS COSAS QUE POR DEFECTO WINDOWS NO TIENE ACTIVAS)


function Configurar-ExPolicy {

Write-Host "`n --- Cambiar Execution Policy ---"
Write-Host "1) Restringida (Más segura)"

#RemoteSigned lo que hace es que permite ejecutar scripts creados localmente y de internet unicamente si estan firmados por un agente de confianza
Write-Host "2) RemoteSigned (Recomendada)"
Write-Host "3) No restringida (Permite pero da advertencias)"
Write-Host "4) Bypass (Permite sin advertencia, buena para automatismos)"

$opcion = Read-Host "Seleccione una opción"

switch ($opcion) {

    "1" { Set-ExecutionPolicy Restricted -Scope LocalMachine -Force }
    "2" { Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force }
    "3" { Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force }
    "4" { Set-ExecutionPolicy Bypass -Scope LocalMachine -Force }
    
    default { Write-Host "Opción no válida"}
    
    }
    Write-Host "Execution Policy cambiada correctamente"
}

#==========================================

#FUNCION CAMBIAR UAC (Es el contro de cuentas de usuario, para cambios no autorizados etc.)

function Configurar-UAC {

    Write-Host "`n--- Configurar UAC (Control de Cuentas de Usuario) ---"
    Write-Host "1) Máxima seguridad (notificar siempre)"
    Write-Host "2) Nivel por defecto"
    Write-Host "3) Nivel bajo (menos avisos)"
    Write-Host "4) Desactivar UAC (no recomendado)"

    $opcion = Read-Host "Seleccione una opción"

#IMPORTANTE!!!!! LAS RUTAS QUE SE PONEN SON LAS RUTAS A TRAVES DE LAS CUALES SE CAMBIAN ESTAS POLITOCAS
#SIEMPRE SON ESTAS POR DEFECTO , LOS VALORES, LO MISMO, POR DEFECTO HACEN "x" EN ESTE CASO, LO CORRESPONDIENTE A LA OPCION
#DE HECHO, LO VOY A COPIAR POR SI SE QUIERE MODIFICAR MAS TARDE


#0	ElevateWithoutPrompt	Elevar automáticamente sin preguntar	sEGURIDAD: Baja
#1	PromptForCredentialsOnSecureDesktop	Pedir credenciales en escritorio seguro	SEGURIDAD Alta
#2	PromptForConsentOnSecureDesktop	Pedir consentimiento en escritorio seguro	SEGURIDAD Alta
#3	PromptForCredentials	Pedir credenciales (sin escritorio seguro)	SEGURIDAD Media
#4	PromptForConsent	Pedir consentimiento (sin escritorio seguro)	SEGURIDAD Media
#5	PromptForConsentForNonWindowsBinaries	Pedir consentimiento solo para apps no-Windows	SEGURIDAD Media (valor por defecto)






    switch ($opcion) {
        "1" { Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System `
        -Name "ConsentPromptBehaviorAdmin" -Value 2 }
        "2" {Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System `
        -Name "ConsentPromptBehaviorAdmin" -Value 5}
        "3" {Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System `
        -Name "ConsentPromptBehaviorAdmin" -Value 0}
        "4" {Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System `
        -Name "EnableLUA" -Value 0}

        default { Write-Host "Opción no válida" }
    }

    Write-Host "UAC configurado correctamente"

}

#He decidido crear otra funcion al igual que la hice en el script de gestion de usuarios para poder ver los permisos de cada uno
#Creo que viene bien para la funcion de despues de la gestion de privilegios
#Pensaba que no hacia falta pero el Silently... es necesario ya que si no, falla si no encuentra usuarios del grupo admin


function VerUsuarios  {

    $usuarios = Get-LocalUser

    foreach ($user in $usuarios) {

        $es_admin = Get-LocalGroupMember -Group "Administrators" -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $user.Name }

        if ($es_admin) {$rol = "Administrador"}

        else {$rol = "Usuario normal"}

        Write-Host "Usuario: $($user.Name)"
        Write-Host "  Estado: $($user.Enabled)"
        Write-Host "  Privilegios: $rol"
        Write-Host ""
    }
}



#========================================
#FUNCION GESTIONAR PRIVILEGIOS

function Gestionar-Privilegios {

    Write-Host "`n--- Gestión de privilegios de usuarios ---"
    Write-Host "1) Añadir usuario al grupo Administradores"
    Write-Host "2) Quitar usuario del grupo Administradores"
    Write-Host "3) Ver usuarios y sus privilegios"

    $opcion = Read-Host "Seleccione una opción"

    switch ($opcion) {
        "1" { 
            $usuario = Read-Host "Nombre del usuario"
            Add-LocalGroupMember -Group "Administrators" -Member $usuario
            Write-Host "Usuario añadido."
        }

        "2" { 
            $usuario = Read-Host "Nombre del usuario"
            Remove-LocalGroupMember -Group "Administrators" -Member $usuario
            Write-Host "Usuario eliminado."
        }

        "3" { VerUsuarios }

        default { Write-Host "Opción no válida." }
    }
}






#=============================================
#FUNCION PARA ACTIVAR O DESACTIVAR ADMIN (ROOT)


function Gestionar-Root {

    Write-Host "`n--- Gestión del usuario Administrador ---"
    Write-Host "1) Activar Administrador"
    Write-Host "2) Desactivar Administrador"

    $opcion = Read-Host "Seleccione una opción"

    switch ($opcion) {
        "1" { Enable-LocalUser -Name "Administrator"; Write-Host "Administrador (root) Activo"}
        "2" { Disable-LocalUser -Name "Administrator"; Write-Host "Administrador (root) Desactivado"}
        default {Write-Host "Opción invalida"}
    }
}

#================================
#FUNCION PERMISOS DE CARPETA 
#El comando icacls es el que se usa para gestionar todos los comandos de gestion de permisos de carpetas y demas en Windows por defecto


function Permisos-Carpetas {

    $ruta = Read-Host "Introduzca la ruta completa de la carpeta qu quiere gestionar"
    if ( -not (Test-Path $ruta ) ) {
        Write-Host "La ruta no existe o no la ha escrito correctamente"
        return
    }

    Write-Host " 1) Dar control a los admin"
    Write-Host " 2) Dar lectura a los usuarios"
    Write-Host " 3) Quitar permisos heredados ( Recomendado si hay subcarpetas importantes dentro de la ruta escrita)"
    Write-Host " 4) Listar las carpetas dentro de la ruta"

    $opcion = Read-Host "Seleccione una opción"

    switch ($opcion) {

        "1" {
        icacls $ruta /grant Administrators:F /T
            Write-Host "Permisos aplicados correctamente"

        }
        
        "2" {
            icacls $ruta /grant Users:R /T
                Write-Host "Permisos aplicados correctamente"
    
        }

        "3" {
            icacls $ruta /inheritance:d
                Write-Host "La herencia ha sido desactivada correctamente"
        
        }

        "4" {
            Write-Host "Carpetas dentro de $ruta "

            Get-ChildItem -Path $ruta -Directory | Select-Object Name, Fullname
        }

        default {
            Write-Host "Opcion no valida"
            }
    }

}



#==========================================
#MENU

do {
    Write-Host "`nSeleccione una opción:"
    Write-Host "1) Cambiar ExecutionPolicy"
    Write-Host "2) Configurar UAC"
    Write-Host "3) Activar/Desactivar Administrador"
    Write-Host "4) Gestionar permisos NTFS (carpetas )"
    Write-Host "5) Gestionar privilegios de usuarios"
    Write-Host "6) Salir"

    $opcion = Read-Host "Opción"

    switch ($opcion) {
        "1" { Configurar-ExPolicy } 
        "2" { Configurar-UAC }
        "3" { Gestionar-Root } 
        "4" { Permisos-carpetas } 
        "5" { Gestionar-Privilegios } 
        "6" { Write-Host "Saliendo del módulo de permisos..." }
        default { Write-Host "ERROR: Seleccione una opción válida (1-6)" }
    }
} while ($opcion -ne "6")