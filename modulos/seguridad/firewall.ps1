
#=============================== AÑADIR COMPROBACION DE ADMIN





#===================================================================


#================================= FUNCION ACTIVAR FIREWALL =============================

function activar-firewall { 
    
    do{
        Write-Host "`nElija el perfil para el que quiere activar el Firewall"
        Write-Host "`n 1) Domain"
        Write-Host " 2) Public"
        Write-Host " 3) Private"
        Write-Host " 4) Todas"
        Write-Host " 5) Volver" -ForegroundColor Cyan


        $opcion = Read-Host "Opcion"

        switch ($opcion) {

            "1" {Set-NetFirewallProfile -Profile Domain -Enabled True
                Write-Host "Activado el firewall para el perfil Domain"
                break
            }

            "2" {Set-NetFirewallProfile -Profile Public -Enabled True
                Write-Host "Activado el firewall para el perfil Publico"
                break
                }

            "3" {Set-NetFirewallProfile -Profile Private -Enabled True
                Write-Host "Activado el firewall para el perfil Privado"
                break
                }

            "4" {Set-NetFirewallProfile -Profile Public,Domain,Private -Enabled True
                Write-Host "Activado el firewall para todos los perfiles"
                break
                }

            "5" { Write-Host "Volviendo al menú" -ForegroundColor Cyan
                break
                } 
        
            default { Write-Host "ERROR: ELIJA UN NUMERO DEL 1-5" -ForegroundColor Red}
        } 

    } while ( $opcion -ne "5" )

}



#================================= FUNCION DESACTIVAR FIREWALL =============================


function desactivar-firewall { 
    
    do{
        Write-Host "`nElija el perfil para el que quiere desactivar el Firewall"
        Write-Host "`n 1) Domain"
        Write-Host " 2) Public"
        Write-Host " 3) Private"
        Write-Host " 4) Todas"
        Write-Host " 5) Volver" -ForegroundColor Cyan


        $opcion = Read-Host "Opcion"

        switch ($opcion) {

            "1" {Set-NetFirewallProfile -Profile Domain -Enabled False
                Write-Host "Desactivado el firewall para el perfil Domain"
                break
            }

            "2" {Set-NetFirewallProfile -Profile Public -Enabled False
                Write-Host "Desactivado el firewall para el perfil Publico"
                break
                }

            "3" {Set-NetFirewallProfile -Profile Private -Enabled False
                Write-Host "Desactivado el firewall para el perfil Privado"
                break
                }

            "4" {Set-NetFirewallProfile -Profile Public,Domain,Private -Enabled False
                Write-Host "Desactivado el firewall para todos los perfiles"
                break
                }

            "5" { Write-Host "Volviendo al menú" -ForegroundColor Cyan
                break
                } 
        
            default { Write-Host "ERROR: ELIJA UN NUMERO DEL 1-5" -ForegroundColor Red}
        } 

    } while ( $opcion -ne "5" )

}
#========================================================================================



#========================== FUNCION APERTURA DE PUERTOS ==========================

function abrir-puertos {
    Write-Host "`nApertura de puertos"

    do {
        $puerto = Read-Host "Introduzca el número de puerto que desea abrir"

        if ($puerto -notmatch '^\d+$') {
            Write-Host "ERROR: Introduzca un número de puerto válido" -ForegroundColor Red
        }
    } until ($puerto -match '^\d+$')

    do {
        $protocolo = Read-Host "Introduzca el protocolo (UDP/TCP)"

        if ($protocolo -notin @("TCP","UDP")) {
            Write-Host "ERROR: Introduzca TCP o UDP" -ForegroundColor Red
        }
    } until ($protocolo -in @("TCP","UDP"))

    $nombre = "Puerto_$puerto `_$protocolo`_Allow"

    New-NetFirewallRule -DisplayName $nombre -Direction Inbound -Protocol $protocolo

    Write-Host "Puerto $puerto/$protocolo abierto correctamente" -ForegroundColor Green
}





#================================================ Bloquear puertos


function bloquear-puertos {

    Write-Host "`nBloqueo de puertos" 

    do {
        $puerto = Read-Host "Introduzca el número de puerto que desea bloquear"

        if ($puerto -notmatch '^\d+$') {
            Write-Host "ERROR: Introduzca un número de puerto válido" -ForegroundColor Red
        }

    } until ($puerto -match '^\d+$')

    do {
        $protocolo = Read-Host "Protocolo (TCP/UDP)"

        if ($protocolo -notin @("TCP","UDP")) {
            Write-Host "ERROR: Introduzca TCP o UDP" -ForegroundColor Red
        }

    } until ($protocolo -in @("TCP","UDP"))

    $nombre = "Puerto_$puerto`_$protocolo`_Block"

    New-NetFirewallRule -DisplayName $nombre -Direction Inbound -Protocol $protocolo -LocalPort $puerto -Action Block

    Write-Host "Puerto $puerto/$protocolo bloqueado correctamente" -ForegroundColor Green
}






#============================================== FUNCION BLOQUEAR DESBLOQUEAR APLICACIONES =================================

function bloquear-apps {

 do {   $programa = Read-Host "Escriba la ruta completa de la aplicacion que quiere bloquear ej.(C:\Program Files\Google\Chrome\Application\chrome.exe)" 


    # SE COMPRUEBA QUE LA RUTA EXISTE

        if ( -not (Test-Path $programa) ) {

            Write-Host "ERROR: La ruta no existe" -ForegroundColor Red
        } 
        
} until ( Test-Path $programa)

        $app = Split-Path $programa -Leaf #Lo que hace esto es reducir el nombre al (x.exe)
        $nombreregla = "$app Block"
            
            
        New-NetFirewallRule -DisplayName "$nombreregla" -Direction Inbound,Outbound -Program "$programa" -Action Block 
        Write-Host "Aplicación bloqueada correctamente: $app"

}


function permitir-apps {

 do {   $programa = Read-Host "Escriba la ruta completa de la aplicacion que quiere permitir ej.(C:\Program Files\Google\Chrome\Application\chrome.exe)"


    # SE COMPRUEBA QUE LA RUTA EXISTE

        if ( -not (Test-Path $programa) ) {

            Write-Host "ERROR: La ruta no existe"  -ForegroundColor Red
        }
        
} until ( Test-Path $programa)

        $app = Split-Path $programa -Leaf #Lo que hace esto es reducir el nombre al (x.exe)
        $nombreregla = "$app Allow"
            
            
        New-NetFirewallRule -DisplayName "$nombreregla" -Direction Inbound,Outbound -Program "$programa" -Action Allow 
        Write-Host "Aplicación permitida correctamente: $app"

}


#===============================================


#=========================== FUNCION RESTAURAR EL FIREWALL ===============================

function default-firewall {
    do { $opcion = Read-Host "`n¿Está seguro de querer restablecer el firewall? s/n"
    
    switch ($opcion) {

        "s" { netsh advfirewall reset 
            Write-Host "`nFirewall reseteado correctamente"
            break
        }

        "n" {Write-Host "`n Operación cancelada"
         
            break
        }

        default {Write-Host 'ERROR: Introduzca  "s" o "n"'  -ForegroundColor Red }
    }


    } until ($opcion -in @("s","n"))


     
}
#=====================================



#======================= FUNCION DE LISTAR REGLAS (CON FILTRO PARA LAS NUESTRAS)


function listar-reglas {
    Get-NetFirewallRule |
    Where-Object { $_.DisplayName -match "Block-|Allow-" } |
    Format-Table DisplayName, Direction, Action, Program, Enabled -AutoSize
}


#=================================== MENU PRINCIPAL ============================

do {
    Write-Host " =================== CONFIGURACION DE SEGURIDAD ==================="
    Write-Host "`nSeleccione una opción:"
    Write-Host "1) Activar Firewall"
    Write-Host "2) Desactivar Firewall"
    Write-Host "3) Resetear Firewall"
    Write-Host "4) Bloquear Aplicacion"
    Write-Host "5) Permitir Aplicacion"
    Write-Host "6) Abrir Puerto"
    Write-Host "7) Bloquear Puerto"
    Write-Host "8) Listar reglas del Firewall"
    Write-Host "9) Salir" -ForegroundColor Cyan


    $opcion = Read-Host "Opción"

    switch ($opcion) {
        "1" { activar-firewall } 
        "2" { desactivar-firewall }
        "3" { default-firewall } 
        "4" { bloquear-apps } 
        "5" { permitir-apps } 
        "6" { abrir-puertos }
        "7" { bloquear-puertos}
        "8" { listar-reglas}
        "9" { Write-Host "Saliendo de la configuración de firewall..." -ForegroundColor Green}
        default { Write-Host "ERROR: Seleccione una opción válida (1-9)"  -ForegroundColor Red}
    }
} while ($opcion -ne "9")
