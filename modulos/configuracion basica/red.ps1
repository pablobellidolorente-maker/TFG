
Write-Host "========== CONFIGURACION DE RED =========="

#Declaramos funciones para que asi se las pueda llamar desde el menu interactivo

#------------------------------------------------------------------------------
#FUNCION PARA VER ADAPTADORES DE RED

function Ver-Adaptadores {
    
    Write-Host "`n--- Adaptadores de Red Disponibles ---"
    Write-Host ""
    
    $adaptadores = @(Get-NetAdapter | Where-Object { $_.Status -ne "Not Present" })


    
    if ($adaptadores.Count -eq 0) {
        Write-Host "ERROR: No se encontraron adaptadores de red" -ForegroundColor Red
        return
    }
    
    $contador = 1
    $adaptadores | ForEach-Object {
        Write-Host "($contador) Nombre: $($_.Name)"
        Write-Host "   Estado: $($_.Status)"
        Write-Host "   Descripcion: $($_.InterfaceDescription)"
        Write-Host "   Tipo: $($_.MediaConnectionState)"
        Write-Host ""
        $contador++
    }
}

#------------------------------------------------------------------------------
#FUNCION PARA CONFIGURAR IP ESTATICA

function Configurar-IPEstatica {
    
    Write-Host "`n--- Configurar IP Estatica ---"
    Write-Host ""
    
    Ver-Adaptadores
    
    $numeroAdaptador = Read-Host "Seleccione el numero del adaptador a configurar"
    $adaptadores = @(Get-NetAdapter | Where-Object { $_.Status -ne "Not Present" })


    
    # Validacion del numero de adaptador
    if ([int]$numeroAdaptador -lt 1 -or [int]$numeroAdaptador -gt $adaptadores.Count) {
        Write-Host "ERROR: Numero de adaptador no valido" -ForegroundColor Red
        return
    }
    
    $adaptadorSeleccionado = $adaptadores[[int]$numeroAdaptador - 1]
    $nombreAdaptador = $adaptadorSeleccionado.Name
    
    Write-Host "`nConfiguracion actual de ${nombreAdaptador}:"
    $ipActual = Get-NetIPAddress -InterfaceAlias $nombreAdaptador -AddressFamily IPv4 -ErrorAction SilentlyContinue
    
    if ($ipActual) {
        Write-Host "IP actual: $($ipActual.IPAddress)"
        Write-Host "Mascara de red: $($ipActual.PrefixLength)"
    } else {
        Write-Host "Sin configuracion de IP estatica"
    }
    
    Write-Host ""
    
    # Solicitar nueva IP (con validaciones)
    do {
        $nuevaIP = Read-Host "Introduzca la nueva direccion IP"
        
        if ([string]::IsNullOrWhiteSpace($nuevaIP)) {
            Write-Host "ERROR: La IP no puede estar vacia" -ForegroundColor Red
            continue
        }
        
        # Validar formato de IP
        if ($nuevaIP -notmatch '^(\d{1,3}\.){3}\d{1,3}$') {
            Write-Host "ERROR: Formato de IP invalido (use formato XXX.XXX.XXX.XXX)" -ForegroundColor Red
            continue
        }
        
        $partes = $nuevaIP -split '\.'
        $valida = $true
        foreach ($parte in $partes) {
            if ([int]$parte -gt 255) {
                Write-Host "ERROR: Cada octeto debe ser menor o igual a 255" -ForegroundColor Red
                $valida = $false
                break
            }
        }
        
        if ($valida) {
            break
        }
    } while ($true)
    
    # Solicitar mascara de red (CIDR)
    do {
        $prefixLength = Read-Host "Introduzca la mascara de red en CIDR (normalmente 24)"
        
        if ([string]::IsNullOrWhiteSpace($prefixLength)) {
            Write-Host "ERROR: La mascara no puede estar vacia" -ForegroundColor Red
            continue
        }
        
        if ($prefixLength -notmatch '^\d+$' -or [int]$prefixLength -lt 1 -or [int]$prefixLength -gt 32) {
            Write-Host "ERROR: Introduzca un valor entre 1 y 32" -ForegroundColor Red
            continue
        }
        
        break
    } while ($true)
    
    # Solicitar puerta de enlace
    do {
        $gateway = Read-Host "Introduzca la puerta de enlace (gateway)"
        
        if ([string]::IsNullOrWhiteSpace($gateway)) {
            Write-Host "ERROR: El gateway no puede estar vacio" -ForegroundColor Red
            continue
        }
        
        if ($gateway -notmatch '^(\d{1,3}\.){3}\d{1,3}$') {
            Write-Host "ERROR: Formato de gateway invalido" -ForegroundColor Red
            continue
        }
        
        $partes = $gateway -split '\.'
        $valida = $true
        foreach ($parte in $partes) {
            if ([int]$parte -gt 255) {
                Write-Host "ERROR: Cada octeto debe ser menor o igual a 255" -ForegroundColor Red
                $valida = $false
                break
            }
        }
        
        if ($valida) {
            break
        }
    } while ($true)
    
    Write-Host ""
    Write-Host "Resumen de configuracion:"
    Write-Host "Adaptador: $nombreAdaptador"
    Write-Host "IP: $nuevaIP"
    Write-Host "Mascara (CIDR): /$prefixLength"
    Write-Host "Gateway: $gateway"
    Write-Host ""
    
    $confirmacion = Read-Host "Desea aplicar esta configuracion? (s/n)"
    
    if ($confirmacion -ne "s") {
        Write-Host "Configuracion cancelada"
        return
    }
    
    try {
        Remove-NetIPAddress -InterfaceAlias $nombreAdaptador -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
        Remove-NetRoute -InterfaceAlias $nombreAdaptador -Confirm:$false -ErrorAction SilentlyContinue
        
        New-NetIPAddress -InterfaceAlias $nombreAdaptador -IPAddress $nuevaIP -PrefixLength $prefixLength -DefaultGateway $gateway | Out-Null
        
        Write-Host "IP estatica configurada correctamente" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: No se pudo aplicar la configuracion" -ForegroundColor Red
        Write-Host "Detalles: $_"
    }
}

#------------------------------------------------------------------------------
#FUNCION PARA CONFIGURAR DHCP

function Prueba {

    Write-Host "`n--- Configurar DHCP (IP Automatica) ---"
    Write-Host ""

    Ver-Adaptadores

    $numeroAdaptador = Read-Host "Seleccione el numero del adaptador"
    $adaptadores = @(Get-NetAdapter | Where-Object { $_.Status -ne "Not Present" })

    if ([int]$numeroAdaptador -lt 1 -or [int]$numeroAdaptador -gt $adaptadores.Count) {
        Write-Host "ERROR: Numero de adaptador no valido" -ForegroundColor Red
        return
    }

    $adaptadorSeleccionado = $adaptadores[[int]$numeroAdaptador - 1]
    $nombreAdaptador = $adaptadorSeleccionado.Name

    $confirmacion = Read-Host "Desea activar DHCP en el adaptador '$nombreAdaptador'? (s/n)"
    if ($confirmacion -ne "s") {
        Write-Host "Operacion cancelada"
        return
    }

    try {
        Remove-NetIPAddress -InterfaceAlias $nombreAdaptador -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
        Remove-NetRoute -InterfaceAlias $nombreAdaptador -Confirm:$false -ErrorAction SilentlyContinue

        Set-NetIPInterface -InterfaceAlias $nombreAdaptador -Dhcp Enabled
        Set-DnsClientServerAddress -InterfaceAlias $nombreAdaptador -ResetServerAddresses

        Write-Host " DHCP activado correctamente en $nombreAdaptador" -ForegroundColor Green
        Start-Sleep -Seconds 3

        $ipDHCP = Get-NetIPAddress -InterfaceAlias $nombreAdaptador -AddressFamily IPv4 -ErrorAction SilentlyContinue
        if ($ipDHCP) {
            Write-Host "IP asignada: $($ipDHCP.IPAddress)"
        } else {
            Write-Host "Aun no se ha asignado una IP via DHCP"
        }
    }
    catch {
        Write-Host "ERROR: No se pudo configurar DHCP" -ForegroundColor Red
        Write-Host "Detalles: $_"
    }
}


#------------------------------------------------------------------------------
#FUNCION PARA CONFIGURAR DNS

function Configurar-DNS {
    
    Write-Host "`n--- Configurar DNS ---"
    Write-Host ""
    
    Ver-Adaptadores
    
    $numeroAdaptador = Read-Host "Seleccione el numero del adaptador a configurar DNS"
    $adaptadores = @(Get-NetAdapter | Where-Object { $_.Status -ne "Not Present" })


    
    if ([int]$numeroAdaptador -lt 1 -or [int]$numeroAdaptador -gt $adaptadores.Count) {
        Write-Host "ERROR: Numero de adaptador no valido" -ForegroundColor Red
        return
    }
    
    $adaptadorSeleccionado = $adaptadores[[int]$numeroAdaptador - 1]
    $nombreAdaptador = $adaptadorSeleccionado.Name
    
    Write-Host ""
    Write-Host "DNS preconfigurados:"
    Write-Host "1) Google (8.8.8.8, 8.8.4.4)"
    Write-Host "2) Cloudflare (1.1.1.1, 1.0.0.1)"
    Write-Host "3) OpenDNS (208.67.222.222, 208.67.220.220)"
    Write-Host "4) Configurar DNS personalizados"
    Write-Host "5) Ver DNS actual"
    
    $opcion = Read-Host "Seleccione una opcion"
    
    switch ($opcion) {
        "1" { 
            $dns1 = "8.8.8.8"
            $dns2 = "8.8.4.4"
            Write-Host "DNS seleccionados: Google"
        }
        "2" { 
            $dns1 = "1.1.1.1"
            $dns2 = "1.0.0.1"
            Write-Host "DNS seleccionados: Cloudflare"
        }
        "3" { 
            $dns1 = "208.67.222.222"
            $dns2 = "208.67.220.220"
            Write-Host "DNS seleccionados: OpenDNS"
        }
        "4" {
            do {
                $dns1 = Read-Host "Introduzca el primer servidor DNS"
                
                if ([string]::IsNullOrWhiteSpace($dns1)) {
                    Write-Host "ERROR: DNS no puede estar vacio" -ForegroundColor Red
                    continue
                }
                
                if ($dns1 -notmatch '^(\d{1,3}\.){3}\d{1,3}$') {
                    Write-Host "ERROR: Formato de DNS invalido" -ForegroundColor Red
                    continue
                }
                
                break
            } while ($true)
            
            do {
                $dns2 = Read-Host "Introduzca el segundo servidor DNS (puede dejar en blanco)"
                
                if ([string]::IsNullOrWhiteSpace($dns2)) {
                    $dns2 = ""
                    break
                }
                
                if ($dns2 -notmatch '^(\d{1,3}\.){3}\d{1,3}$') {
                    Write-Host "ERROR: Formato de DNS invalido" -ForegroundColor Red
                    continue
                }
                
                break
            } while ($true)
        }
        "5" {
            Write-Host ""
            Write-Host "DNS actual para ${nombreAdaptador}:"
            Get-DnsClientServerAddress -InterfaceAlias $nombreAdaptador -AddressFamily IPv4
            return
        }
        default { 
            Write-Host "ERROR: Opcion no valida" -ForegroundColor Red
            return
        }
    }
    
    $confirmacion = Read-Host "Desea aplicar estos cambios de DNS? (s/n)"
    
    if ($confirmacion -ne "s") {
        Write-Host "Configuracion cancelada"
        return
    }
    
    try {
        if ([string]::IsNullOrWhiteSpace($dns2)) {
            Set-DnsClientServerAddress -InterfaceAlias $nombreAdaptador -ServerAddresses $dns1
        } else {
            Set-DnsClientServerAddress -InterfaceAlias $nombreAdaptador -ServerAddresses $dns1, $dns2
        }
        
        Write-Host "DNS configurado correctamente" -ForegroundColor Green
        Write-Host ""
        Write-Host "Configuracion aplicada:"
        Get-DnsClientServerAddress -InterfaceAlias $nombreAdaptador -AddressFamily IPv4
    } catch {
        Write-Host "ERROR: No se pudo configurar el DNS" -ForegroundColor Red
        Write-Host "Detalles: $_"
    }
}

#------------------------------------------------------------------------------
#FUNCION PARA RENOMBRAR ADAPTADOR DE RED

function Renombrar-Adaptador {

    Write-Host "`n--- Renombrar Adaptador de Red ---`n"

    Ver-Adaptadores

    $numeroAdaptador = Read-Host "Seleccione el numero del adaptador a renombrar"
    $adaptadores = @(Get-NetAdapter | Where-Object { $_.Status -ne "Not Present" })

    # Validacion
    if ([int]$numeroAdaptador -lt 1 -or [int]$numeroAdaptador -gt $adaptadores.Count) {
        Write-Host "ERROR: Numero de adaptador no valido" -ForegroundColor Red
        return
    }

    # Adaptador seleccionado
    $adaptadorSeleccionado = $adaptadores[[int]$numeroAdaptador - 1]
    $nombreActual = $adaptadorSeleccionado.Name

    Write-Host ""
    Write-Host "Nombre actual del adaptador: $nombreActual"

    # Solicitar nuevo nombre
    do {
        $nombreNuevo = Read-Host "Introduzca el nuevo nombre para el adaptador"

        if ([string]::IsNullOrWhiteSpace($nombreNuevo)) {
            Write-Host "ERROR: El nombre no puede estar vacio" -ForegroundColor Red
            continue
        }

        if ($nombreNuevo -eq $nombreActual) {
            Write-Host "ERROR: El nuevo nombre no puede ser igual al anterior" -ForegroundColor Red
            continue
        }

        break
    } while ($true)

    Write-Host ""

    # Mensaje de confirmacion con variables FORZADAS
    $mensaje = "Desea renombrar '$nombreActual' a '$nombreNuevo'? (s/n)"
    $confirmacion = Read-Host $mensaje

    if ($confirmacion -ne "s") {
        Write-Host "Operacion cancelada"
        return
    }

    # Renombrar adaptador
    try {
        Rename-NetAdapter -Name $nombreActual -NewName $nombreNuevo
        Write-Host " Adaptador renombrado correctamente" -ForegroundColor Green
        Write-Host "Nombre anterior: $nombreActual"
        Write-Host "Nombre nuevo: $nombreNuevo"
    }
    catch {
        Write-Host "ERROR: No se pudo renombrar el adaptador" -ForegroundColor Red
        Write-Host "Detalles: $_"
    }
}

#------------------------------------------------------------------------------
#FUNCION PARA VER CONFIGURACION DE RED ACTUAL

function Ver-ConfiguracionRed {
    
    Write-Host "`n--- Configuracion de Red Actual ---"
    Write-Host ""
    
    $adaptadores = @(Get-NetAdapter | Where-Object { $_.Status -ne "Not Present" })



    foreach ($adaptador in $adaptadores) {
        Write-Host "=== Adaptador: $($adaptador.Name) ==="
        Write-Host "Estado: $($adaptador.Status)"
        Write-Host "Descripcion: $($adaptador.InterfaceDescription)"
        Write-Host "Direccion MAC: $($adaptador.MacAddress)"
        Write-Host ""
        
        # IP Configuracion
        Write-Host "Configuracion IPv4:"
        $ipConfig = Get-NetIPAddress -InterfaceAlias $adaptador.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue
        if ($ipConfig) {
            Write-Host "  IP: $($ipConfig.IPAddress)"
            Write-Host "  Mascara (CIDR): /$($ipConfig.PrefixLength)"
        } else {
            Write-Host "  Sin configuracion IPv4"
        }
        
        # Gateway
        $route = Get-NetRoute -InterfaceAlias $adaptador.Name -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue
        if ($route) {
            Write-Host "  Gateway: $($route.NextHop)"
        }
        
        # DNS
        Write-Host "Servidores DNS:"
        $dns = Get-DnsClientServerAddress -InterfaceAlias $adaptador.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue
        if ($dns.ServerAddresses) {
            foreach ($servidor in $dns.ServerAddresses) {
                Write-Host "  - $servidor"
            }
        } else {
            Write-Host "  Sin DNS configurado"
        }
        
        Write-Host ""
    }
}

#=============================================
#MENU PRINCIPAL

do {
    Write-Host "`nSeleccione una opcion:"
    Write-Host "1) Ver adaptadores de red disponibles"
    Write-Host "2) Ver configuracion de red actual"
    Write-Host "3) Configurar IP estatica"
    Write-Host "4) Configurar DHCP (IP automatica)"
    Write-Host "5) Configurar DNS"
    Write-Host "6) Renombrar adaptador de red"
    Write-Host "7) Salir" -ForegroundColor Cyan
    
    $opcion = Read-Host "Opcion"
    
    switch ($opcion) {
        "1" { Ver-Adaptadores }
        "2" { Ver-ConfiguracionRed }
        "3" { Configurar-IPEstatica }
        "4" { Prueba }
        "5" { Configurar-DNS }
        "6" { Renombrar-Adaptador }
        "7" { Write-Host "Saliendo del modulo de configuracion de red..." }
        default { Write-Host "ERROR: Seleccione una opcion valida (1-7)" -ForegroundColor Red}
    }
} while ($opcion -ne "7")
