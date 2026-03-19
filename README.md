# TFG
TFG ASIR 2º Alvaro y Pablo

He pensado que los scripts que vamos a hacer si te paras a pensar, creo que son muy básicos, podemos tocar y complicarlos un poco pero quizá, debido a esto, es más importante como lo compartamentemos , la organizacion y la presentacion.

Por lo que, habia pensado crear un script segun el dpto para el cual se vaya a usar cada equipo, me refiero a: Crear funciones que varien segun el departamento y un menú como el de (opciones_dpt.ps1) y crear algo al usuario intuitivo y que quede bonito con la presentacion, ya que, la seguridad, abrir puertos, instalar apps y demás si te pones a pensarlo, son 1 linea o 2 de codigo cada una.

Por cierto, puedes ejecutar copiando y pegando en powershell lo que he hecho para verlo en el ordenador de la empresa, y te deja porque realmente no hace nada, si no para que veas la presentación, ya que creo que la ejecucion de scripts en lo que es el equipo de kyndril no deja.

:)

Esta es la estructura sugerida por COPI y me parece bien

Metete al VS del github para verlo Bien



/TFG-AutoDeploy/
│
├── launcher.sh
├── README.md
│
├── modulos/
│   ├── config_basica/
│   │   ├── hostname.sh
│   │   ├── red.sh
│   │   ├── usuarios.sh
│   │   └── permisos.sh
│   │
│   ├── seguridad/
│   │   ├── firewall.sh
│   │   ├── hardening.sh
│   │   ├── auditoria.sh
│   │   └── antivirus.sh
│   │
│   ├── software/
│   │   ├── instalar_chrome.sh
│   │   ├── instalar_vscode.sh
│   │   ├── instalar_7zip.sh
│   │   ├── instalar_ofimatica.sh
│   │   └── instalar_paquetes.sh
│   │
│   └── departamentos/
│       ├── dpto_informatica.sh
│       ├── dpto_administracion.sh
│       ├── dpto_rrhh.sh
│       └── dpto_marketing.sh
│
├── data/
│   ├── paquetes_informatica.txt
│   ├── paquetes_admin.txt
│   ├── firewall_rules.conf
│   └── hardening.conf
│
└── logs/
    └── (se generan automáticamente)
