
Write-Host "========== CONFIGURACIÓN DE RED =========="

#Declaramos funciones para que así se las pueda llamar desde el menú interactivo

#------------------------------------------------------------------------------
#FUNCIÓN PARA VER ADAPTADORES DE RED

function Ver-Adaptadores {
    
    Write-Host "`n--- Adaptadores de Red Disponibles ---"
    Write-Host ""
    
    $adaptadores = Get-NetAdapter
    
    if ($adaptadores.Count -eq 0) {
        Write-Host "ERROR: No se encontraron adaptadores de red"
        return
    }
    
    $contador = 1
    $adaptadores | ForEach-Object {
        Write-Host "$contador) Nombre: $($_.Name)"
        Write-Host "   Estado: $($_.Status)"
        Write-Host "   Descripción: $($_.InterfaceDescription)"
        Write-Host "   Tipo: $($_.MediaConnectionState)"
        Write-Host ""
        $contador++
    }
}

#------------------------------------------------------------------------------
#FUNCIÓN PARA CONFIGURAR IP ESTÁTICA

function Configurar-IPEstatica {
    
    Write-Host "`n--- Configurar IP Estática ---"
    Write-Host ""
    
    Ver-Adaptadores
    
    $numeroAdaptador = Read-Host "Seleccione el número del adaptador a configurar"
    $adaptadores = Get-NetAdapter
    
    # Validación del número de adaptador
    if ([int]$numeroAdaptador -lt 1 -or [int]$numeroAdaptador -gt $adaptadores.Count) {
        Write-Host "ERROR: Número de adaptador no válido"
        return
    }
    
    $adaptadorSeleccionado = $adaptadores[[int]$numeroAdaptador - 1]
    $nombreAdaptador = $adaptadorSeleccionado.Name
    
    Write-Host "`nConfiguración actual de $nombreAdaptador:"
    $ipActual = Get-NetIPAddress -InterfaceAlias $nombreAdaptador -AddressFamily IPv4 -ErrorAction SilentlyContinue
    
    if ($ipActual) {
        Write-Host "IP actual: $($ipActual.IPAddress)"
        Write-Host "Máscara de red: $($ipActual.PrefixLength)"
    } else {
        Write-Host "Sin configuración de IP estática"
    }
    
    Write-Host ""
    
    # Solicitar nueva IP (con validaciones)
    do {
        $nuevaIP = Read-Host "Introduzca la nueva dirección IP"
        
        if ([string]::IsNullOrWhiteSpace($nuevaIP)) {
            Write-Host "ERROR: La IP no puede estar vacía"
            continue
        }
        
        # Validar formato de IP
        if ($nuevaIP -notmatch '^(\d{1,3}\.){3}\d{1,3}$') {
            Write-Host "ERROR: Formato de IP inválido (use formato XXX.XXX.XXX.XXX)"
            continue
        }
        
        $partes = $nuevaIP -split '\.'
        $valida = $true
        foreach ($parte in $partes) {
            if ([int]$parte -gt 255) {
                Write-Host "ERROR: Cada octeto debe ser menor o igual a 255"
                $valida = $false
                break
            }
        }
        
        if ($valida) {
            break
        }
    } while ($true)
    
    # Solicitar máscara de red (CIDR)
    do {
        $prefixLength = Read-Host "Introduzca la máscara de red en CIDR (normalmente 24)"
        
        if ([string]::IsNullOrWhiteSpace($prefixLength)) {
            Write-Host "ERROR: La máscara no puede estar vacía"
            continue
        }
        
        if ($prefixLength -notmatch '^\d+$' -or [int]$prefixLength -lt 1 -or [int]$prefixLength -gt 32) {
            Write-Host "ERROR: Introduzca un valor entre 1 y 32"
            continue
        }
        
        break
    } while ($true)
    
    # Solicitar puerta de enlace
    do {
        $gateway = Read-Host "Introduzca la puerta de enlace (gateway)"
        
        if ([string]::IsNullOrWhiteSpace($gateway)) {
            Write-Host "ERROR: El gateway no puede estar vacío"
            continue
        }
        
        if ($gateway -notmatch '^(\d{1,3}\.){3}\d{1,3}$') {
            Write-Host "ERROR: Formato de gateway inválido"
            continue
        }
        
        $partes = $gateway -split '\.'
        $valida = $true
        foreach ($parte in $partes) {
            if ([int]$parte -gt 255) {
                Write-Host "ERROR: Cada octeto debe ser menor o igual a 255"
                $valida = $false
                break
            }
        }
        
        if ($valida) {
            break
        }
    } while ($true)
    
    Write-Host ""
    Write-Host "Resumen de configuración:"
    Write-Host "Adaptador: $nombreAdaptador"
    Write-Host "IP: $nuevaIP"
    Write-Host "Máscara (CIDR): /$prefixLength"
    Write-Host "Gateway: $gateway"
    Write-Host ""
    
    $confirmacion = Read-Host "¿Desea aplicar esta configuración? (s/n)"
    
    if ($confirmacion -ne "s") {
        Write-Host "Configuración cancelada"
        return
    }
    
    try {
        Remove-NetIPAddress -InterfaceAlias $nombreAdaptador -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
        Remove-NetRoute -InterfaceAlias $nombreAdaptador -Confirm:$false -ErrorAction SilentlyContinue
        
        New-NetIPAddress -InterfaceAlias $nombreAdaptador -IPAddress $nuevaIP -PrefixLength $prefixLength -DefaultGateway $gateway | Out-Null
        
        Write-Host "✓ IP estática configurada correctamente"
    } catch {
        Write-Host "ERROR: No se pudo aplicar la configuración"
        Write-Host "Detalles: $_"
    }
}

#------------------------------------------------------------------------------
#FUNCIÓN PARA CONFIGURAR DHCP

function Configurar-DHCP {
    
    Write-Host "`n--- Configurar DHCP ---"
    Write-Host ""
    
    Ver-Adaptadores
    
    $numeroAdaptador = Read-Host "Seleccione el número del adaptador a configurar"
    $adaptadores = Get-NetAdapter
    
    if ([int]$numeroAdaptador -lt 1 -or [int]$numeroAdaptador -gt $adaptadores.Count) {
        Write-Host "ERROR: Número de adaptador no válido"
        return
    }
    
    $adaptadorSeleccionado = $adaptadores[[int]$numeroAdaptador - 1]
    $nombreAdaptador = $adaptadorSeleccionado.Name
    
    Write-Host ""
    $confirmacion = Read-Host "¿Desea configurar $nombreAdaptador para obtener IP automáticamente (DHCP)? (s/n)"
    
    if ($confirmacion -ne "s") {
        Write-Host "Configuración cancelada"
        return
    }
    
    try {
        Remove-NetIPAddress -InterfaceAlias $nombreAdaptador -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
        Remove-NetRoute -InterfaceAlias $nombreAdaptador -Confirm:$false -ErrorAction SilentlyContinue
        
        Set-NetIPInterface -InterfaceAlias $nombreAdaptador -Dhcp Enabled
        
        Write-Host "✓ DHCP configurado correctamente en $nombreAdaptador"
        Write-Host "ADVERTENCIA: Espere unos segundos a que el adaptador obtenga IP..."
        Start-Sleep -Seconds 3
        
        $ipDHCP = Get-NetIPAddress -InterfaceAlias $nombreAdaptador -AddressFamily IPv4 -ErrorAction SilentlyContinue
        if ($ipDHCP) {
            Write-Host "IP asignada: $($ipDHCP.IPAddress)"
        }
    } catch {
        Write-Host "ERROR: No se pudo configurar DHCP"
        Write-Host "Detalles: $_"
    }
}

#------------------------------------------------------------------------------
#FUNCIÓN PARA CONFIGURAR DNS

function Configurar-DNS {
    
    Write-Host "`n--- Configurar DNS ---"
    Write-Host ""
    
    Ver-Adaptadores
    
    $numeroAdaptador = Read-Host "Seleccione el número del adaptador a configurar DNS"
    $adaptadores = Get-NetAdapter
    
    if ([int]$numeroAdaptador -lt 1 -or [int]$numeroAdaptador -gt $adaptadores.Count) {
        Write-Host "ERROR: Número de adaptador no válido"
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
    
    $opcion = Read-Host "Seleccione una opción"
    
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
                    Write-Host "ERROR: DNS no puede estar vacío"
                    continue
                }
                
                if ($dns1 -notmatch '^(\d{1,3}\.){3}\d{1,3}$') {
                    Write-Host "ERROR: Formato de DNS inválido"
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
                    Write-Host "ERROR: Formato de DNS inválido"
                    continue
                }
                
                break
            } while ($true)
        }
        "5" {
            Write-Host ""
            Write-Host "DNS actual para $nombreAdaptador:"
            Get-DnsClientServerAddress -InterfaceAlias $nombreAdaptador -AddressFamily IPv4
            return
        }
        default { 
            Write-Host "ERROR: Opción no válida"
            return
        }
    }
    
    $confirmacion = Read-Host "¿Desea aplicar estos cambios de DNS? (s/n)"
    
    if ($confirmacion -ne "s") {
        Write-Host "Configuración cancelada"
        return
    }
    
    try {
        if ([string]::IsNullOrWhiteSpace($dns2)) {
            Set-DnsClientServerAddress -InterfaceAlias $nombreAdaptador -ServerAddresses $dns1
        } else {
            Set-DnsClientServerAddress -InterfaceAlias $nombreAdaptador -ServerAddresses $dns1, $dns2
        }
        
        Write-Host "✓ DNS configurado correctamente"
        Write-Host ""
        Write-Host "Configuración aplicada:"
        Get-DnsClientServerAddress -InterfaceAlias $nombreAdaptador -AddressFamily IPv4
    } catch {
        Write-Host "ERROR: No se pudo configurar el DNS"
        Write-Host "Detalles: $_"
    }
}

#------------------------------------------------------------------------------
#FUNCIÓN PARA RENOMBRAR ADAPTADOR DE RED

function Renombrar-Adaptador {
    
    Write-Host "`n--- Renombrar Adaptador de Red ---"
    Write-Host ""
    
    Ver-Adaptadores
    
    $numeroAdaptador = Read-Host "Seleccione el número del adaptador a renombrar"
    $adaptadores = Get-NetAdapter
    
    if ([int]$numeroAdaptador -lt 1 -or [int]$numeroAdaptador -gt $adaptadores.Count) {
        Write-Host "ERROR: Número de adaptador no válido"
        return
    }
    
    $adaptadorSeleccionado = $adaptadores[[int]$numeroAdaptador - 1]
    $nombreActual = $adaptadorSeleccionado.Name
    
    Write-Host ""
    Write-Host "Nombre actual: $nombreActual"
    
    do {
        $nombreNuevo = Read-Host "Introduzca el nuevo nombre para el adaptador"
        
        if ([string]::IsNullOrWhiteSpace($nombreNuevo)) {
            Write-Host "ERROR: El nombre no puede estar vacío"
            continue
        }
        
        if ($nombreNuevo -eq $nombreActual) {
            Write-Host "ERROR: El nuevo nombre no puede ser igual al anterior"
            continue
        }
        
        break
    } while ($true)
    
    Write-Host ""
    $confirmacion = Read-Host "¿Desea renombrar $nombreActual a $nombreNuevo? (s/n)"
    
    if ($confirmacion -ne "s") {
        Write-Host "Operación cancelada"
        return
    }
    
    try {
        Rename-NetAdapter -Name $nombreActual -NewName $nombreNuevo
        Write-Host "✓ Adaptador renombrado correctamente"
        Write-Host "Nombre anterior: $nombreActual"
        Write-Host "Nombre nuevo: $nombreNuevo"
    } catch {
        Write-Host "ERROR: No se pudo renombrar el adaptador"
        Write-Host "Detalles: $_"
    }
}

#------------------------------------------------------------------------------
#FUNCIÓN PARA VER CONFIGURACIÓN DE RED ACTUAL

function Ver-ConfiguracionRed {
    
    Write-Host "`n--- Configuración de Red Actual ---"
    Write-Host ""
    
    $adaptadores = Get-NetAdapter
    
    foreach ($adaptador in $adaptadores) {
        Write-Host "=== Adaptador: $($adaptador.Name) ==="
        Write-Host "Estado: $($adaptador.Status)"
        Write-Host "Descripción: $($adaptador.InterfaceDescription)"
        Write-Host "Dirección MAC: $($adaptador.MacAddress)"
        Write-Host ""
        
        # IP Configuration
        Write-Host "Configuración IPv4:"
        $ipConfig = Get-NetIPAddress -InterfaceAlias $adaptador.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue
        if ($ipConfig) {
            Write-Host "  IP: $($ipConfig.IPAddress)"
            Write-Host "  Máscara (CIDR): /$($ipConfig.PrefixLength)"
        } else {
            Write-Host "  Sin configuración IPv4"
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
#MENÚ PRINCIPAL

do {
    Write-Host "`nSeleccione una opción:"
    Write-Host "1) Ver adaptadores de red disponibles"
    Write-Host "2) Ver configuración de red actual"
    Write-Host "3) Configurar IP estática"
    Write-Host "4) Configurar DHCP (IP automática)"
    Write-Host "5) Configurar DNS"
    Write-Host "6) Renombrar adaptador de red"
    Write-Host "7) Salir"
    
    $opcion = Read-Host "Opción"
    
    switch ($opcion) {
        "1" { Ver-Adaptadores }
        "2" { Ver-ConfiguracionRed }
        "3" { Configurar-IPEstatica }
        "4" { Configurar-DHCP }
        "5" { Configurar-DNS }
        "6" { Renombrar-Adaptador }
        "7" { Write-Host "Saliendo del módulo de configuración de red..." }
        default { Write-Host "ERROR: Seleccione una opción válida (1-7)" }
    }
} while ($opcion -ne "7")
