#Crearemos las carpetas necesarias para una empresa promedio, y asi despues dar permisos a los usuarios pertinentes

# ============================
#   IMPORTAR MODULOS DE LOGGING
# ============================

. ".\modulos\logging-basico.ps1"
. ".\modulos\logging-detallado.ps1"


Write-Host "========= CREACION DE ESTRUCTURA DE CARPETAS ========="

#Array lista de carpetas a crear

$carpetas = @(
    "C:\Datos",
    "C:\Proyectos",
    "C:\Departamentos",
    "C:\UsuariosEmpresa",
    "C:\Temp",
    "C:\Logs"
)

#Creacion de las carpetas y su comprobacion de si ya existen

foreach ($carpeta in $carpetas) {
    if (-not (Test-Path $carpeta)){
        Write-Host "Creando carpeta $carpeta"
        New-Item -ItemType Directory -Path $carpeta | Out-Null
    } else {
        Write-Host "La carpeta ya existe: $carpeta"    
    }
}
Write-Host ""
Write-Host "Estructura creada correctamente" -ForegroundColor Green
