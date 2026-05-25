# 🛡️ AutoDeploy & Hardening de Windows  
Automatización completa de configuración, seguridad, uditoría e instalación de software en equipos Windows.
Este proyecto contiene un conjunto modular de scripts PowerShell diseñados para:
- Configurar políticas de seguridad  
- Activar/desactivar protecciones de Microsoft Defender  
- Gestionar auditorías del sistema  
- Instalar software automáticamente mediante Winget  
- Aplicar hardening básico  
- Facilitar despliegues en entornos educativos o mpresariales  
---
## 📂 Estructura del repositorio
```
/TFG-AutoDeploy/
│
├── MMindice.ps1                # Script principal que carga el menú general
├── README.md                   # Este archivo
│
├── modulos/
│   ├── config_basica/          # Configuración inicial el sistema
│   │   ├── hostname.ps1
│   │   ├── red.ps1
│   │   ├── usuarios.ps1
│   │   └── permisos.ps1
│   │
│   ├── seguridad/              # Hardening y Defender
│   │   ├── defender.ps1
│   │   ├── firewall.ps1
│   │   ├── hardening.ps1
│   │   └── auditoria.ps1
│   │
│   ├── software/               # Instalación automática e 
│   │   ├── Msoftware.ps1
│   │   ├── listas_software/
│   │       ├── basico.txt
│   │       ├── drivers.txt
│   │       ├── informatica.txt
│   │       ├── marketing.txt
│   │       ├── ofimatica.txt
│   │       ├── utilidades.txt
│   │       ├── ventas.txt
│   │ 
│
│
└── logs/
│   │       
│   ├── logging-basico.ps1
│   ├──logging-detallado.ps1                     # Logs generados utomáticamente
```
---
## 🚀 Cómo ejecutar el proyecto
### 1️⃣ Abrir PowerShell como Administrador  
Es obligatorio para:
- Defender  
- Firewall  
- Auditorías  
- Instalación de software  
- Hardening  
### 2️⃣ Permitir ejecución de scripts (solo la primera ez)
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```
### 3️⃣ Ejecutar el lanzador principal
```powershell
.\launcher.ps1
```
Esto abrirá el menú general del proyecto.
---
## 🛡️ Módulo de Microsoft Defender
Incluye:
- Activar protecciones  
- Desactivar protecciones (respetando Tamper Protection)  
- Ver estado de Defender  
- Escaneos rápidos, completos y personalizados  
- Exclusiones  
- Amenazas detectadas  
### ⚠️ Nota importante sobre Tamper Protection
Si **Tamper Protection está activado**, Windows **NO ermite desactivar**:
- Protección en tiempo real  
- Protección basada en la nube  
- Otras protecciones críticas  
El script detecta automáticamente esta condición y uestra un mensaje claro.
---
## 📊 Módulo de Auditoría del Sistema
Incluye:
- Ver auditorías configuradas  
- Activar auditorías recomendadas  
- Desactivar auditorías  
- Exportar auditorías a archivo (si no existe, se crea utomáticamente)  
Ejemplo de exportación:
```powershell
Introduce la ruta donde guardar el archivo (ej: :\auditoria.txt)
```
Si escribes solo:
```
auditoria.txt
```
Se guardará en la carpeta actual.
---
## 📦 Instalación automática de software
Los scripts usan **Winget** para instalar aplicaciones omo:
- Google Chrome  
- Visual Studio Code  
- 7zip  
- LibreOffice / Office  
- Paquetes personalizados por departamento  
Cada módulo lee un archivo `.txt` con la lista de aquetes a instalar.
Ejemplo:
```
Google.Chrome
Microsoft.VisualStudioCode
7zip.7zip
```
---
## 🧱 Hardening básico
Incluye:
- Configuración de firewall  
- Reglas de seguridad  
- Restricciones de permisos  
- Configuración de políticas recomendadas  
---
## 📝 Logs
Todos los módulos pueden generar logs automáticos en:
```
/logs/
```
Esto permite documentar la ejecución para auditorías o nformes.
---
## 🧪 Requisitos
- Windows 10 / 11  
- PowerShell 5.1 o superior  
- Winget instalado  
- Ejecución como Administrador  
---
## 📚 Licencia
Proyecto académico para TFG.  
Uso permitido para entornos educativos y pruebas.
---
## 👨‍💻 Autor
Pablo Bellido  
TFG — Automatización y Hardening de Sistemas Windows  
2026