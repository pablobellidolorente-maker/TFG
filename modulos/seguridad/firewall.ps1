Write-Host " =================== CONFIGURACION DE SEGURIDAD ==================="



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
        Write-Host " 5) Volver"


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

            "5" { Write-Host "Volviendo al menú"
                break
                }
        
            default { Write-Host "ERROR: ELIJA UN NUMERO DEL 1-5"}
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
        Write-Host " 5) Volver"


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

            "5" { Write-Host "Volviendo al menú"
                break
                }
        
            default { Write-Host "ERROR: ELIJA UN NUMERO DEL 1-5"}
        } 

    } while ( $opcion -ne "5" )

}
#========================================================================================



#========================== FUNCION APERTURA DE PUERTOS ==========================







#================================================




#============================================== FUNCION BLOQUEAR DESBLOQUEAR APLICACIONES =================================

function bloquear-apps {

 do {   $programa = Read-Host "Escriba la ruta completa de la aplicacion que quiere bloquear ej.(C:\Program Files\Google\Chrome\Application\chrome.exe)"


    # SE COMPRUEBA QUE LA RUTA EXISTE

        if ( -not (Test-Path $programa) ) {

            Write-Host "ERROR: La ruta no existe"
        } 
        
} until ( Test-Path $programa)

        $app = Split-Path $programa -Leaf #Lo que hace esto es reducir el nombre al (x.exe)
        $nombreregla = "$app Block"
            
            
        New-NetFirewallRule -DisplayName "$nombreregla" -Direction Inbound,Outbound -Program "$programa" -Action Block 
        Write-Host "Aplicación bloqueada correctamente: $app"

}


function permitir-apps {

 do {   $programa = Read-Host "Escriba la ruta completa de la aplicacion que quiere bloquear ej.(C:\Program Files\Google\Chrome\Application\chrome.exe)"


    # SE COMPRUEBA QUE LA RUTA EXISTE

        if ( -not (Test-Path $programa) ) {

            Write-Host "ERROR: La ruta no existe"
        } 
        
} until ( Test-Path $programa)

        $app = Split-Path $programa -Leaf #Lo que hace esto es reducir el nombre al (x.exe)
        $nombreregla = "$app Block"
            
            
        New-NetFirewallRule -DisplayName "$nombreregla" -Direction Inbound,Outbound -Program "$programa" -Action Allow 
        Write-Host "Aplicación permitida correctamente: $app"

}


#===============================================


#=========================== FUNCION RESTAURAR EL FIREWALL ===============================

function reset-firewall {
    do { $opcion = Read-Host "`n¿Está seguro de querer restablecer el firewall? s/n"
    
    switch ($opcion) {

        "s" { netsh advfirewall reset 
            Write-Host "`nFirewall reseteado correctamente"
            break
        }

        "n" {Write-Host "`n Operación cancelada"
         
            break
        }
    }


    } until ($opcion -in @("s","n"))


     
}