# ============================
#   IMPORTAR MODULOS DE LOGGING
# ============================

. ".\modulos\logging-basico.ps1"
. ".\modulos\logging-detallado.ps1"


Write-Host "========== CONFIGURACION DEL SISTEMA =========="

#--------------------------------------------------------------
# CONFIGURAR ZONA HORARIA
#--------------------------------------------------------------

function Configurar-ZonaHoraria {

    Write-Host "`n--- Configurar Zona Horaria ---"
    Write-Host ""

    $zonaActual = Get-TimeZone
    Write-Host "Zona horaria actual: $($zonaActual.DisplayName)"
    Write-Host ""

    Write-Host "Zonas horarias disponibles:"
    Write-Host "1) (UTC-05:00) Hora del Este"
    Write-Host "2) (UTC-06:00) Hora Central"
    Write-Host "3) (UTC-07:00) Hora de Montana"
    Write-Host "4) (UTC-08:00) Hora del Pacifico"
    Write-Host "5) (UTC+00:00) GMT"
    Write-Host "6) (UTC+01:00) Europa Central"
    Write-Host "7) (UTC+02:00) Oriente Medio"
    Write-Host "8) (UTC+08:00) China"
    Write-Host "9) (UTC+09:00) Japon"
    Write-Host "10) Ver todas las zonas horarias"

    $opcion = Read-Host "Seleccione una opcion"

    switch ($opcion) {
        "1" { Set-TimeZone -Id "Eastern Standard Time"; Write-Host "Zona horaria cambiada a UTC-05" }
        "2" { Set-TimeZone -Id "Central Standard Time"; Write-Host "Zona horaria cambiada a UTC-06" }
        "3" { Set-TimeZone -Id "Mountain Standard Time"; Write-Host "Zona horaria cambiada a UTC-07" }
        "4" { Set-TimeZone -Id "Pacific Standard Time"; Write-Host "Zona horaria cambiada a UTC-08" }
        "5" { Set-TimeZone -Id "GMT Standard Time"; Write-Host "Zona horaria cambiada a UTC+00" }
        "6" { Set-TimeZone -Id "Romance Standard Time"; Write-Host "Zona horaria cambiada a UTC+01" }
        "7" { Set-TimeZone -Id "Egypt Standard Time"; Write-Host "Zona horaria cambiada a UTC+02" }
        "8" { Set-TimeZone -Id "China Standard Time"; Write-Host "Zona horaria cambiada a UTC+08" }
        "9" { Set-TimeZone -Id "Tokyo Standard Time"; Write-Host "Zona horaria cambiada a UTC+09" }
        "10" { Get-TimeZone -ListAvailable | Format-Table -Property ID, DisplayName -AutoSize }
        default { Write-Host "ERROR: Opcion no valida" -ForegroundColor Red }
    }
}

#--------------------------------------------------------------
# CONFIGURAR IDIOMA
#--------------------------------------------------------------

function Configurar-Idioma {

    Write-Host "`n--- Configurar Idioma ---"
    Write-Host ""

    $idiomaActual = Get-WinUILanguageOverride
    Write-Host "Idioma actual: $idiomaActual"
    Write-Host ""

    Write-Host "Seleccione un idioma:"
    Write-Host "1) Espanol (Espana)"
    Write-Host "2) Espanol (Mexico)"
    Write-Host "3) Ingles (Estados Unidos)"
    Write-Host "4) Ingles (Reino Unido)"
    Write-Host "5) Frances"
    Write-Host "6) Aleman"
    Write-Host "7) Italiano"

    $opcion = Read-Host "Seleccione una opcion"

    switch ($opcion) {
        "1" { Set-WinUILanguageOverride -Language es-ES; Write-Host "Requiere reinicio" }
        "2" { Set-WinUILanguageOverride -Language es-MX; Write-Host "Requiere reinicio" }
        "3" { Set-WinUILanguageOverride -Language en-US; Write-Host "Requiere reinicio" }
        "4" { Set-WinUILanguageOverride -Language en-GB; Write-Host "Requiere reinicio" }
        "5" { Set-WinUILanguageOverride -Language fr-FR; Write-Host "Requiere reinicio" }
        "6" { Set-WinUILanguageOverride -Language de-DE; Write-Host "Requiere reinicio" }
        "7" { Set-WinUILanguageOverride -Language it-IT; Write-Host "Requiere reinicio" }
        default { Write-Host "ERROR: Opcion no valida" -ForegroundColor Red }
    }
}

#--------------------------------------------------------------
# CONFIGURAR TECLADO
#--------------------------------------------------------------

function Configurar-Teclado {

    Write-Host "`n--- Configurar Teclado ---"
    Write-Host ""

    $teclados = Get-WinUserLanguageList
    Write-Host "Distribuciones actuales:"
    $teclados | Format-Table -Property LanguageTag, Autonym
    Write-Host ""

    Write-Host "Seleccione una distribucion:"
    Write-Host "1) Espanol (Espana)"
    Write-Host "2) Espanol (Latinoamerica)"
    Write-Host "3) Ingles (Estados Unidos)"
    Write-Host "4) Ingles (Reino Unido)"
    Write-Host "5) Frances"
    Write-Host "6) Aleman"

    $opcion = Read-Host "Seleccione una opcion"

    $lista = New-WinUserLanguageList

    switch ($opcion) {
        "1" { $lista.Add("es-ES") }
        "2" { $lista.Add("es-MX") }
        "3" { $lista.Add("en-US") }
        "4" { $lista.Add("en-GB") }
        "5" { $lista.Add("fr-FR") }
        "6" { $lista.Add("de-DE") }
        default { Write-Host "ERROR: Opcion no valida" -ForegroundColor Red; return }
    }

    Set-WinUserLanguageList $lista -Force
    Write-Host "Teclado actualizado"
}

#--------------------------------------------------------------
# ACTUALIZAR SISTEMA
#--------------------------------------------------------------

function Actualizar-Sistema {

    Write-Host "`n--- Actualizar Sistema ---"
    Write-Host ""

    $confirmacion = Read-Host "Desea continuar? (s/n)"
    if ($confirmacion -ne "s") { Write-Host "Cancelado"; return }

    try {
        $session = New-Object -ComObject Microsoft.Update.Session
        $searcher = $session.CreateUpdateSearcher()
        $result = $searcher.Search("IsInstalled=0")

        if ($result.Updates.Count -eq 0) {
            Write-Host "El sistema esta actualizado"
            return
        }

        Write-Host "Actualizaciones encontradas:"
        foreach ($u in $result.Updates) { Write-Host "- $($u.Title)" }

        $instalar = Read-Host "Instalar actualizaciones? (s/n)"
        if ($instalar -ne "s") { Write-Host "Cancelado"; return }

        $coll = New-Object -ComObject Microsoft.Update.UpdateColl
        foreach ($u in $result.Updates) { $coll.Add($u) | Out-Null }

        $installer = $session.CreateUpdateInstaller()
        $installer.Updates = $coll
        $res = $installer.Install()

        if ($res.RebootRequired) {
            Write-Host "Actualizaciones instaladas. Se requiere reinicio."
            $r = Read-Host "Reiniciar ahora? (s/n)"
            if ($r -eq "s") { Restart-Computer -Force }
        } else {
            Write-Host "Actualizaciones instaladas correctamente" -ForegroundColor Green
        }

    } catch {
        Write-Host "ERROR: No se pudo acceder a Windows Update" -ForegroundColor Red
    }
}

#--------------------------------------------------------------
# VER INFORMACION DEL SISTEMA
#--------------------------------------------------------------

function Ver-InfoSistema {

    Write-Host "`n--- Informacion del Sistema ---"
    Write-Host ""

    $info = Get-ComputerInfo

    Write-Host "Equipo: $($info.CsComputerName)"
    Write-Host "Dominio: $($info.CsDomain)"
    Write-Host "Fabricante: $($info.CsManufacturer)"
    Write-Host "Modelo: $($info.CsModel)"
    Write-Host ""

    Write-Host "Sistema Operativo: $($info.OsName)"
    Write-Host "Version: $($info.OsVersion)"
    Write-Host "Arquitectura: $($info.OsArchitecture)"
    Write-Host ""

    $cpu = Get-WmiObject Win32_Processor | Select-Object -First 1
    Write-Host "Procesador: $($cpu.Name)"
    Write-Host "Nucleos: $($cpu.NumberOfCores)"
    Write-Host "Hilos: $($cpu.NumberOfLogicalProcessors)"
    Write-Host ""

    $mem = Get-WmiObject Win32_ComputerSystem
    $ram = [math]::Round($mem.TotalPhysicalMemory / 1GB, 2)
    Write-Host "RAM total: $ram GB"
    Write-Host ""

    $tz = Get-TimeZone
    Write-Host "Zona horaria: $($tz.DisplayName)"
    Write-Host "UTC: $($tz.BaseUtcOffset)"
    Write-Host "Hora actual: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"
}

#--------------------------------------------------------------
# MENU PRINCIPAL
#--------------------------------------------------------------

do {
    Write-Host "`nSeleccione una opcion:"
    Write-Host "1) Configurar Zona Horaria"
    Write-Host "2) Configurar Idioma"
    Write-Host "3) Configurar Teclado"
    Write-Host "4) Actualizar Sistema"
    Write-Host "5) Ver Informacion del Sistema"
    Write-Host "6) Salir"

    $op = Read-Host "Opcion"

    switch ($op) {
        "1" { Configurar-ZonaHoraria }
        "2" { Configurar-Idioma }
        "3" { Configurar-Teclado }
        "4" { Actualizar-Sistema }
        "5" { Ver-InfoSistema }
        "6" { Write-Host "Saliendo..." }
        default { Write-Host "ERROR: Opcion no valida" -ForegroundColor Red }
    }

} while ($op -ne "6")
