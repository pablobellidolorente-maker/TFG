
Write-Host "========== CONFIGURACIÓN DEL SISTEMA =========="

#Declaramos funciones para que así se las pueda llamar desde el menú interactivo

#------------------------------------------------------------------------------
#CONFIGURAR ZONA HORARIA

function Configurar-ZonaHoraria {
    
    Write-Host "`n--- Configurar Zona Horaria ---"
    Write-Host ""
    
    # Mostrar zona horaria actual
    $zonaActual = Get-TimeZone
    Write-Host "Zona horaria actual: $($zonaActual.DisplayName)"
    Write-Host ""
    
    Write-Host "Zonas horarias disponibles (seleccione por número):"
    Write-Host "1) (UTC-05:00) Hora de este - Norteamérica"
    Write-Host "2) (UTC-06:00) Hora central - Norteamérica"
    Write-Host "3) (UTC-07:00) Hora de montaña - Norteamérica"
    Write-Host "4) (UTC-08:00) Hora del Pacífico - Norteamérica"
    Write-Host "5) (UTC+00:00) Monrovia, Casablanca, Dublín"
    Write-Host "6) (UTC+01:00) Ámsterdam, Berlín, París, Madrid"
    Write-Host "7) (UTC+02:00) Cairo, Helsinki, Estambul"
    Write-Host "8) (UTC+08:00) Hong Kong, Singapur, Pekín"
    Write-Host "9) (UTC+09:00) Tokio, Seúl, Osaka"
    Write-Host "10) Ver todas las zonas horarias disponibles"
    
    $opcion = Read-Host "Seleccione una opción"
    
    switch ($opcion) {
        "1" { Set-TimeZone -Id "Eastern Standard Time"; Write-Host "Zona horaria cambiada a: Hora de este (UTC-05:00)" }
        "2" { Set-TimeZone -Id "Central Standard Time"; Write-Host "Zona horaria cambiada a: Hora central (UTC-06:00)" }
        "3" { Set-TimeZone -Id "Mountain Standard Time"; Write-Host "Zona horaria cambiada a: Hora de montaña (UTC-07:00)" }
        "4" { Set-TimeZone -Id "Pacific Standard Time"; Write-Host "Zona horaria cambiada a: Hora del Pacífico (UTC-08:00)" }
        "5" { Set-TimeZone -Id "GMT Standard Time"; Write-Host "Zona horaria cambiada a: UTC±00:00" }
        "6" { Set-TimeZone -Id "Romance Standard Time"; Write-Host "Zona horaria cambiada a: Hora de Europa Central (UTC+01:00)" }
        "7" { Set-TimeZone -Id "Egypt Standard Time"; Write-Host "Zona horaria cambiada a: Hora de Oriente Medio (UTC+02:00)" }
        "8" { Set-TimeZone -Id "China Standard Time"; Write-Host "Zona horaria cambiada a: Hora de China (UTC+08:00)" }
        "9" { Set-TimeZone -Id "Tokyo Standard Time"; Write-Host "Zona horaria cambiada a: Hora de Tokio (UTC+09:00)" }
        "10" { 
            Write-Host ""
            Get-TimeZone -ListAvailable | Format-Table -Property ID, DisplayName -AutoSize
        }
        default { Write-Host "ERROR: Opción no válida"  -ForegroundColor Red }
    }
}

#------------------------------------------------------------------------------
#CONFIGURAR IDIOMA Y LOCALE

function Configurar-Idioma {
    
    Write-Host "`n--- Configurar Idioma y Locale ---"
    Write-Host ""
    
    # Mostrar idioma actual
    $idiomas = Get-WinUILanguageOverride
    Write-Host "Idioma actual del sistema: $idiomas"
    Write-Host ""
    
    Write-Host "Seleccione un idioma:"
    Write-Host "1) Español (España)"
    Write-Host "2) Español (México)"
    Write-Host "3) Inglés (Estados Unidos)"
    Write-Host "4) Inglés (Reino Unido)"
    Write-Host "5) Francés (Francia)"
    Write-Host "6) Alemán (Alemania)"
    Write-Host "7) Italiano (Italia)"
    
    $opcion = Read-Host "Seleccione una opción"
    
    switch ($opcion) {
        "1" { 
            Set-WinUILanguageOverride -Language es-ES
            Write-Host "!!!ADVERTENCIA: El cambio de idioma requiere reinicio del sistema"  -ForegroundColor Yellow
        }
        "2" { 
            Set-WinUILanguageOverride -Language es-MX
            Write-Host "!!!ADVERTENCIA: El cambio de idioma requiere reinicio del sistema"  -ForegroundColor Yellow
        }
        "3" { 
            Set-WinUILanguageOverride -Language en-US
            Write-Host "!!!ADVERTENCIA: El cambio de idioma requiere reinicio del sistema"  -ForegroundColor Yellow
        }
        "4" { 
            Set-WinUILanguageOverride -Language en-GB
            Write-Host "!!!ADVERTENCIA: El cambio de idioma requiere reinicio del sistema"  -ForegroundColor Yellow
        }
        "5" { 
            Set-WinUILanguageOverride -Language fr-FR
            Write-Host "!!!ADVERTENCIA: El cambio de idioma requiere reinicio del sistema"  -ForegroundColor Yellow
        }
        "6" { 
            Set-WinUILanguageOverride -Language de-DE
            Write-Host "!!!ADVERTENCIA: El cambio de idioma requiere reinicio del sistema"  -ForegroundColor Yellow
        }
        "7" { 
            Set-WinUILanguageOverride -Language it-IT
            Write-Host "!!!ADVERTENCIA: El cambio de idioma requiere reinicio del sistema"  -ForegroundColor Yellow
        }
        default { Write-Host "ERROR: Opción no válida"  -ForegroundColor Red }
    }
}

#------------------------------------------------------------------------------
#CONFIGURAR DISTRIBUCIÓN DE TECLADO

function Configurar-Teclado {
    
    Write-Host "`n--- Configurar Distribución de Teclado ---"
    Write-Host ""
    
    $teclados = Get-WinUserLanguageList
    Write-Host "Distribuciones de teclado actuales:"
    $teclados | Format-Table -Property LanguageTag, Autonym
    Write-Host ""
    
    Write-Host "Seleccione una distribución de teclado:"
    Write-Host "1) Español (España) - Teclado QWERTY"
    Write-Host "2) Español (Latinoamérica) - Teclado QWERTY"
    Write-Host "3) Inglés (Estados Unidos) - Teclado QWERTY"
    Write-Host "4) Inglés (Reino Unido) - Teclado QWERTY"
    Write-Host "5) Francés (Francia) - Teclado AZERTY"
    Write-Host "6) Alemán (Alemania) - Teclado QWERTZ"
    
    $opcion = Read-Host "Seleccione una opción"
    
    $userLanguageList = New-WinUserLanguageList
    
    switch ($opcion) {
        "1" { 
            $userLanguageList.Add("es-ES")
            Set-WinUserLanguageList $userLanguageList -Force
            Write-Host "Teclado cambiado a: Español (España)"
        }
        "2" { 
            $userLanguageList.Add("es-MX")
            Set-WinUserLanguageList $userLanguageList -Force
            Write-Host "Teclado cambiado a: Español (Latinoamérica)"
        }
        "3" { 
            $userLanguageList.Add("en-US")
            Set-WinUserLanguageList $userLanguageList -Force
            Write-Host "Teclado cambiado a: Inglés (Estados Unidos)"
        }
        "4" { 
            $userLanguageList.Add("en-GB")
            Set-WinUserLanguageList $userLanguageList -Force
            Write-Host "Teclado cambiado a: Inglés (Reino Unido)"
        }
        "5" { 
            $userLanguageList.Add("fr-FR")
            Set-WinUserLanguageList $userLanguageList -Force
            Write-Host "Teclado cambiado a: Francés (Francia)"
        }
        "6" { 
            $userLanguageList.Add("de-DE")
            Set-WinUserLanguageList $userLanguageList -Force
            Write-Host "Teclado cambiado a: Alemán (Alemania)"
        }
        default { Write-Host "ERROR: Opción no válida"  -ForegroundColor Red }
    }
}

#------------------------------------------------------------------------------
#ACTUALIZAR SISTEMA OPERATIVO

function Actualizar-Sistema {
    
    Write-Host "`n--- Actualizar Sistema Operativo ---"
    Write-Host ""
    
    Write-Host "!!!ADVERTENCIA: Este proceso puede tardar bastante tiempo"  -ForegroundColor Yellow
    Write-Host "!!!ADVERTENCIA: El sistema podría reiniciarse durante las actualizaciones"  -ForegroundColor Yellow
    Write-Host ""
    
    $confirmacion = Read-Host "¿Desea continuar con la actualización? (s/n)"
    
    if ($confirmacion -ne "s") {
        Write-Host "Actualización cancelada"
        return
    }
    
    Write-Host ""
    Write-Host "Buscando actualizaciones disponibles..."
    Write-Host ""
    
    # Usar Windows Update para buscar actualizaciones
    # IMPORTANTE: Este script requiere acceso como administrador
    
    try {
        # Crear objeto de actualización de Windows
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateupdateSearcher()
        
        Write-Host "Buscando actualizaciones disponibles..."
        $SearchResult = $UpdateSearcher.Search("IsInstalled=0")
        
        if ($SearchResult.Updates.Count -eq 0) {
            Write-Host "✓ El sistema ya está actualizado"
            return
        }
        
        Write-Host "Se encontraron $($SearchResult.Updates.Count) actualizaciones disponibles:"
        Write-Host ""
        
        foreach ($update in $SearchResult.Updates) {
            Write-Host "- $($update.Title)"
        }
        
        Write-Host ""
        $instalar = Read-Host "¿Desea instalar estas actualizaciones? (s/n)"
        
        if ($instalar -ne "s") {
            Write-Host "Instalación de actualizaciones cancelada"
            return
        }
        
        Write-Host ""
        Write-Host "Instalando actualizaciones..."
        
        $UpdatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
        foreach ($update in $SearchResult.Updates) {
            $UpdatesToInstall.Add($update) | Out-Null
        }
        
        $Installer = $UpdateSession.CreateUpdateInstaller()
        $Installer.Updates = $UpdatesToInstall
        $InstallationResult = $Installer.Install()
        
        if ($InstallationResult.Rebootrequired) {
            Write-Host "✓ Actualizaciones instaladas correctamente"
            Write-Host "!!!ADVERTENCIA: El sistema requiere reinicio para completar las actualizaciones"  -ForegroundColor Yellow
            
            $reinicio = Read-Host "¿Desea reiniciar ahora? (s/n)"
            
            if ($reinicio -eq "s") {
                Restart-Computer -Force
            } else {
                Write-Host "El sistema se reiniciará en el próximo arranque"
            }
        } else {
            Write-Host "✓ Actualizaciones instaladas correctamente (sin necesidad de reinicio)"
        }
        
    } catch {
        Write-Host "ERROR: No se pudo acceder a Windows Update" -ForegroundColor Red
        Write-Host "Asegúrese de ejecutar el script como administrador"
    }
}

#------------------------------------------------------------------------------
#VER INFORMACIÓN DEL SISTEMA

function Ver-InfoSistema {
    
    Write-Host "`n--- Información del Sistema ---"
    Write-Host ""
    
    # Información del equipo
    $ComputerInfo = Get-ComputerInfo
    
    Write-Host "=== INFORMACIÓN DEL EQUIPO ==="
    Write-Host "Nombre del equipo: $($ComputerInfo.CsComputerName)"
    Write-Host "Dominio: $($ComputerInfo.CsDomain)"
    Write-Host "Fabricante: $($ComputerInfo.CsManufacturer)"
    Write-Host "Modelo: $($ComputerInfo.CsModel)"
    Write-Host ""
    
    # Información del SO
    Write-Host "=== INFORMACIÓN DEL SISTEMA OPERATIVO ==="
    Write-Host "SO: $($ComputerInfo.OsName)"
    Write-Host "Versión: $($ComputerInfo.OsVersion)"
    Write-Host "Arquitectura: $($ComputerInfo.OsArchitecture)"
    Write-Host "Compilación: $($ComputerInfo.OsBuildNumber)"
    Write-Host ""
    
    # Información de Hardware
    Write-Host "=== INFORMACIÓN DE HARDWARE ==="
    $ProcInfo = Get-WmiObject Win32_Processor | Select-Object -First 1
    Write-Host "Procesador: $($ProcInfo.Name)"
    Write-Host "Núcleos: $($ProcInfo.NumberOfCores)"
    Write-Host "Threads lógicos: $($ProcInfo.NumberOfLogicalProcessors)"
    Write-Host ""
    
    $MemInfo = Get-WmiObject Win32_ComputerSystem
    $MemTotalGB = [math]::Round($MemInfo.TotalPhysicalMemory / 1GB, 2)
    Write-Host "Memoria RAM total: $MemTotalGB GB"
    Write-Host ""
    
    # Información de Zona Horaria
    Write-Host "=== INFORMACIÓN DE LOCALIZACIÓN ==="
    $TimeZone = Get-TimeZone
    Write-Host "Zona horaria: $($TimeZone.DisplayName)"
    Write-Host "UTC: $($TimeZone.BaseUtcOffset)"
    $CurrentTime = Get-Date
    Write-Host "Hora actual: $($CurrentTime.ToString('dd/MM/yyyy HH:mm:ss'))"
}

#=============================================
#MENÚ PRINCIPAL

do {
    Write-Host "`nSeleccione una opción:"
    Write-Host "1) Configurar Zona Horaria"
    Write-Host "2) Configurar Idioma"
    Write-Host "3) Configurar Distribución de Teclado"
    Write-Host "4) Actualizar Sistema Operativo"
    Write-Host "5) Ver Información del Sistema"
    Write-Host "6) Salir" -ForegroundColor Cyan
    
    $opcion = Read-Host "Opción"
    
    switch ($opcion) {
        "1" { Configurar-ZonaHoraria }
        "2" { Configurar-Idioma }
        "3" { Configurar-Teclado }
        "4" { Actualizar-Sistema }
        "5" { Ver-InfoSistema }
        "6" { Write-Host "Saliendo del módulo de configuración del sistema..." }
        default { Write-Host "ERROR: Seleccione una opción válida (1-6)" -ForegroundColor Red }
    }
} while ($opcion -ne "6")
