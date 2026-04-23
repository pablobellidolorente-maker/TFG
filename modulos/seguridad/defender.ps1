
#=============================== AÑADIR COMPROBACION DE ADMIN




#===================================================================


#================================= FUNCION ACTIVAR DEFENDER =============================

function activar-defender {
    
    do{
        Write-Host "`nElija la protección que desea activar"
        Write-Host "`n 1) Protección en tiempo real"
        Write-Host " 2) Protección basada en la nube"
        Write-Host " 3) Envío automático de muestras"
        Write-Host " 4) Todas"
        Write-Host " 5) Volver" -ForegroundColor Cyan

        $opcion = Read-Host "Opcion"

        switch ($opcion) {

            "1" {Set-MpPreference -DisableRealtimeMonitoring $false
                Write-Host "Activada la protección en tiempo real"
                break
            }

            "2" {Set-MpPreference -MAPSReporting Advanced
                Write-Host "Activada la protección basada en la nube"
                break
                }

            "3" {Set-MpPreference -SubmitSamplesConsent Always
                Write-Host "Activado el envío automático de muestras"
                break
                }

            "4" {Set-MpPreference -DisableRealtimeMonitoring $false
                 Set-MpPreference -MAPSReporting Advanced
                 Set-MpPreference -SubmitSamplesConsent Always
                Write-Host "Activadas todas las protecciones"
                break
                }

            "5" { Write-Host "Volviendo al menú" -ForegroundColor Cyan
                break
                } 
        
            default { Write-Host "ERROR: ELIJA UN NUMERO DEL 1-5" -ForegroundColor Red}
        } 

    } while ( $opcion -ne "5" )

}



#================================= FUNCION DESACTIVAR DEFENDER =============================


function desactivar-defender { 
    
    do{
        Write-Host "`nElija la protección que desea desactivar"
        Write-Host "`n 1) Protección en tiempo real"
        Write-Host " 2) Protección basada en la nube"
        Write-Host " 3) Envío automático de muestras"
        Write-Host " 4) Todas"
        Write-Host " 5) Volver" -ForegroundColor Cyan


        $opcion = Read-Host "Opcion"

        switch ($opcion) {

            "1" {Set-MpPreference -DisableRealtimeMonitoring $true
                Write-Host "Desactivada la protección en tiempo real"
                break
            }

            "2" {Set-MpPreference -MAPSReporting Disabled
                Write-Host "Desactivada la protección basada en la nube"
                break
                }

            "3" {Set-MpPreference -SubmitSamplesConsent Never
                Write-Host "Desactivado el envío automático de muestras"
                break
                }

            "4" {Set-MpPreference -DisableRealtimeMonitoring $true
                 Set-MpPreference -MAPSReporting Disabled
                 Set-MpPreference -SubmitSamplesConsent Never
                Write-Host "Desactivadas todas las protecciones"
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



#========================== FUNCION VER ESTADO DE DEFENDER ==========================

function ver-estado-defender {
    Write-Host "`nEstado de Windows Defender:"
    Write-Host "`n================================"
    
    $estado = Get-MpComputerStatus
    
    Write-Host "Protección en tiempo real: $(if ($estado.RealTimeProtectionEnabled) { 'Activada' } else { 'Desactivada' })" -ForegroundColor Green
    Write-Host "Protección basada en nube: $(if ($estado.IsTamperProtected) { 'Activa' } else { 'Inactiva' })" -ForegroundColor Green
    Write-Host "Protección de exploración: $(if ($estado.BehaviorMonitoringEnabled) { 'Activada' } else { 'Desactivada' })" -ForegroundColor Green
    Write-Host "Actualizado: $(if ($estado.AntivirusSignatureLastUpdated -gt (Get-Date).AddDays(-7)) { 'Sí' } else { 'No' })" -ForegroundColor Green
    Write-Host "Última actualización: $($estado.AntivirusSignatureLastUpdated)" -ForegroundColor Green
    Write-Host "`n================================"
}




#================================================ ESCANEO RAPIDO


function escaneo-rapido {

    Write-Host "`nIniciando escaneo rápido..." -ForegroundColor Yellow
    
    Start-MpScan -ScanType QuickScan
    
    Write-Host "Escaneo rápido completado" -ForegroundColor Green
}




#================================================ ESCANEO COMPLETO


function escaneo-completo {

    Write-Host "`n¿Está seguro de que desea realizar un escaneo completo? Puede tardar varias horas" -ForegroundColor Yellow
    
    do { $opcion = Read-Host "¿Continuar? s/n"
    
    switch ($opcion) {

        "s" { Write-Host "`nIniciando escaneo completo..." -ForegroundColor Yellow
             Start-MpScan -ScanType FullScan
             Write-Host "`nEscaneo completo completado" -ForegroundColor Green
            break
        }

        "n" {Write-Host "`nOperación cancelada" -ForegroundColor Cyan
         
            break
        }

        default {Write-Host 'ERROR: Introduzca "s" o "n"'  -ForegroundColor Red }
    }


    } until ($opcion -in @("s","n"))

}
#=====================================



#========================== ESCANEO PERSONALIZADO ==========================

function escaneo-personalizado {
    
    do {   $ruta = Read-Host "Introduzca la ruta de la carpeta que desea escanear ej.(C:\Users\admin\Desktop)"

        if ( -not (Test-Path $ruta) ) {

            Write-Host "ERROR: La ruta no existe" -ForegroundColor Red
        } 
         
    } until ( Test-Path $ruta)

    Write-Host "`nIniciando escaneo en: $ruta" -ForegroundColor Yellow
    
    Start-MpScan -ScanType CustomScan -ScanPath $ruta
    
    Write-Host "Escaneo completado" -ForegroundColor Green
}




#================================================ ACTUALIZAR DEFINICIONES


function actualizar-definiciones {

    Write-Host "`nActualizando definiciones de virus..." -ForegroundColor Yellow
    
    Update-MpSignature
    
    Write-Host "Definiciones actualizadas correctamente" -ForegroundColor Green
}




#================================================ AGREGAR EXCLUSION


function agregar-exclusion {

    do{
        Write-Host "`nElija el tipo de exclusión:"
        Write-Host "`n 1) Carpeta completa"
        Write-Host " 2) Archivo específico"
        Write-Host " 3) Extensión de archivo"
        Write-Host " 4) Volver" -ForegroundColor Cyan

        $opcion = Read-Host "Opcion"

        switch ($opcion) {

            "1" {
                do {   $carpeta = Read-Host "Introduzca la ruta de la carpeta ej.(C:\Users\admin\Desktop)"

                    if ( -not (Test-Path $carpeta) ) {

                        Write-Host "ERROR: La ruta no existe" -ForegroundColor Red
                    } 
                         
                } until ( Test-Path $carpeta)

                Add-MpPreference -ExclusionPath $carpeta
                Write-Host "Carpeta excluida correctamente: $carpeta" -ForegroundColor Green
                break
            }

            "2" {
                do {   $archivo = Read-Host "Introduzca la ruta del archivo ej.(C:\Users\admin\archivo.txt)"

                    if ( -not (Test-Path $archivo) ) {

                        Write-Host "ERROR: La ruta no existe" -ForegroundColor Red
                    } 
                         
                } until ( Test-Path $archivo)

                Add-MpPreference -ExclusionPath $archivo
                Write-Host "Archivo excluido correctamente: $archivo" -ForegroundColor Green
                break
                }

            "3" {
                $extension = Read-Host "Introduzca la extensión ej.(.txt, .exe, .pdf)"
                Add-MpPreference -ExclusionExtension $extension
                Write-Host "Extensión excluida correctamente: $extension" -ForegroundColor Green
                break
                }

            "4" { Write-Host "Volviendo al menú" -ForegroundColor Cyan
                break
                } 
        
            default { Write-Host "ERROR: ELIJA UN NUMERO DEL 1-4" -ForegroundColor Red}
        } 

    } while ( $opcion -ne "4" )
}




#================================================ LISTAR EXCLUSIONES


function listar-exclusiones {

    Write-Host "`nExclusiones configuradas:"
    Write-Host "`n================================"
    
    $exclusiones = Get-MpPreference
    
    Write-Host "`nCarpetas excluidas:"
    if ($exclusiones.ExclusionPath) {
        $exclusiones.ExclusionPath | ForEach-Object { Write-Host "  - $_" }
    } else {
        Write-Host "  Ninguna"
    }
    
    Write-Host "`nArchivos excluidos:"
    if ($exclusiones.ExclusionPath) {
        $exclusiones.ExclusionPath | ForEach-Object { Write-Host "  - $_" }
    } else {
        Write-Host "  Ninguno"
    }
    
    Write-Host "`nExtensiones excluidas:"
    if ($exclusiones.ExclusionExtension) {
        $exclusiones.ExclusionExtension | ForEach-Object { Write-Host "  - $_" }
    } else {
        Write-Host "  Ninguna"
    }
    
    Write-Host "`n================================"
}




#================================================ ELIMINAR EXCLUSION


function eliminar-exclusion {

    do{
        Write-Host "`nElija el tipo de exclusión a eliminar:"
        Write-Host "`n 1) Carpeta"
        Write-Host " 2) Archivo"
        Write-Host " 3) Extensión"
        Write-Host " 4) Volver" -ForegroundColor Cyan

        $opcion = Read-Host "Opcion"

        switch ($opcion) {

            "1" {
                $carpeta = Read-Host "Introduzca la ruta de la carpeta a eliminar"
                Remove-MpPreference -ExclusionPath $carpeta
                Write-Host "Exclusión de carpeta eliminada correctamente" -ForegroundColor Green
                break
            }

            "2" {
                $archivo = Read-Host "Introduzca la ruta del archivo a eliminar"
                Remove-MpPreference -ExclusionPath $archivo
                Write-Host "Exclusión de archivo eliminada correctamente" -ForegroundColor Green
                break
                }

            "3" {
                $extension = Read-Host "Introduzca la extensión a eliminar"
                Remove-MpPreference -ExclusionExtension $extension
                Write-Host "Exclusión de extensión eliminada correctamente" -ForegroundColor Green
                break
                }

            "4" { Write-Host "Volviendo al menú" -ForegroundColor Cyan
                break
                } 
        
            default { Write-Host "ERROR: ELIJA UN NUMERO DEL 1-4" -ForegroundColor Red}
        } 

    } while ( $opcion -ne "4" )
}




#================================================ VER AMENAZAS DETECTADAS


function ver-amenazas {

    Write-Host "`nAmenazas detectadas:"
    Write-Host "`n================================"
    
    $amenazas = Get-MpThreatDetection
    
    if ($amenazas) {
        $amenazas | Format-Table InitialDetectionTime, ThreatName, Severity -AutoSize
    } else {
        Write-Host "No se han detectado amenazas"
    }
    
    Write-Host "`n================================"
}




#=================================== MENU PRINCIPAL ============================

do {
    Write-Host " =================== CONFIGURACION DE DEFENDER ==================="
    Write-Host "`nSeleccione una opción:"
    Write-Host "1) Activar protecciones"
    Write-Host "2) Desactivar protecciones"
    Write-Host "3) Ver estado de Defender"
    Write-Host "4) Escaneo rápido"
    Write-Host "5) Escaneo completo"
    Write-Host "6) Escaneo personalizado"
    Write-Host "7) Actualizar definiciones de virus"
    Write-Host "8) Agregar exclusión"
    Write-Host "9) Listar exclusiones"
    Write-Host "10) Eliminar exclusión"
    Write-Host "11) Ver amenazas detectadas"
    Write-Host "12) Salir" -ForegroundColor Cyan


    $opcion = Read-Host "Opción"

    switch ($opcion) {
        "1" { activar-defender } 
        "2" { desactivar-defender }
        "3" { ver-estado-defender } 
        "4" { escaneo-rapido } 
        "5" { escaneo-completo } 
        "6" { escaneo-personalizado }
        "7" { actualizar-definiciones }
        "8" { agregar-exclusion }
        "9" { listar-exclusiones }
        "10" { eliminar-exclusion }
        "11" { ver-amenazas }
        "12" { Write-Host "Saliendo de la configuración de Defender..." -ForegroundColor Green}
        default { Write-Host "ERROR: Seleccione una opción válida (1-12)"  -ForegroundColor Red}
    }
} while ($opcion -ne "12")

