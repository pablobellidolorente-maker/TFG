# Guia para la memoria del TFG

Este archivo es una plantilla de guia para redactar la memoria final del Trabajo Fin de Grado (TFG). Esta pensada para el proyecto de automatizacion de configuracion, seguridad y software por departamentos, adaptada al ecosistema desarrollado en el repo.

---

## 1. Portada

Incluye:

- Titulo del proyecto.
- Autor/es.
- Tutores.
- Titulacion: ASIR.
- Curso academico.
- Centro educativo.

---

## 2. indice

Lista de secciones con numeros de pagina. Incluye:

- Resumen
- Introduccion
- Objetivos
- Estado del arte
- Metodologia
- Desarrollo del proyecto
- Pruebas y validacion
- Resultados
- Conclusiones
- Bibliografia
- Anexos

---

## 3. Resumen (abstract)

- Breve descripcion del proyecto.
- Objetivos principales.
- Metodo de trabajo.
- Resultados mas relevantes.
- Conclusion o aporte principal.

El resumen debe ser conciso y comprenderse sin leer el resto del documento.

---

## 4. Introduccion

Explica:

- Contexto del proyecto.
- Motivacion para elegirlo.
- Importancia de automatizar configuraciones y seguridad.
- Relacion con el mundo profesional y academico.
- Alcance general del TFG.

---

## 5. Objetivos

Detalla los objetivos generales y especificos:

- Objetivo general: crear un sistema automatizado de configuracion y despliegue por departamentos.
- Objetivos especificos:
  - modularizar scripts por funcion y departamento
  - disenar un menu de seleccion intuitivo
  - garantizar seguridad basica y estandarizacion
  - documentar el proceso y presentar la solucion

Incluye criterios de exito y alcance real del proyecto.

---

## 6. Estado del arte

Describe:

- referencias y proyectos similares.
- herramientas existentes para automatizacion en entornos empresariales.
- buenas practicas en gestion de configuracion y hardening.
- comparacion breve con la solucion del TFG.

Puede incluir:

- PowerShell para Windows
- scripts de despliegue y configuracion
- estructura modular de proyectos

---

## 7. Metodologia

Explica el proceso de trabajo:

- planificacion y organizacion del proyecto.
- fases del desarrollo.
- herramientas usadas: GitHub, VS Code, PowerShell, etc.
- trabajo en equipo y coordinacion.
- criterios para tomar decisiones de diseno.

Incluye un diagrama de fases si quieres.

---

## 8. Desarrollo del proyecto

Presenta la implementacion en detalle:

- estructura del repositorio y razones de diseno.
- descripcion de los modulos principales:
  - `modulos/configuracion basica/`
  - `modulos/seguridad/`
  - `modulos/software/`
  - `modulos/opciones_dpt.ps1`
- logica por departamentos y como se aplica.
- explicacion del flujo de ejecucion.
- decisiones de organizacion y nombres.

Es importante justificar la arquitectura y mostrar ejemplos concretos.

---

## 9. Pruebas y validacion

Incluye:

- como se probo cada modulo.
- escenarios de uso por departamento.
- verificacion de cambios de configuracion.
- pruebas de seguridad basicas.
- resultados de ejecucion y logs generados.

Si no se pudo ejecutar en un entorno real, explica las limitaciones y las pruebas realizadas en entorno de desarrollo.

---

## 10. Resultados

Resume los resultados obtenidos:

- que se ha conseguido automatizar.
- mejoras esperadas en tiempos de despliegue.
- la organizacion amplia del proyecto.
- que queda pendiente o que se puede ampliar.

Incluye una valoracion objetiva sobre el cumplimiento de los objetivos.

---

## 11. Conclusiones

Reflexiona sobre:

- lecciones aprendidas.
- fortalezas del proyecto.
- debilidades o aspectos a mejorar.
- utilidad real del proyecto para el entorno objetivo.
- direccion futura (mejoras, ampliaciones, integracion con mas departamentos o herramientas).

---

## 12. Bibliografia

Lista las fuentes consultadas:

- documentacion tecnica de PowerShell.
- guias de hardening.
- ejemplos de automatizacion.
- articulos y repositorios usados como referencia.

Usa un estilo de cita claro (APA breve, IEEE, etc.).

---

## 13. Anexos

Anade material adicional util:

- capturas de pantalla del proyecto o de menus si es necesario.
- listas de software o configuraciones de ejemplo.
- ejemplos de uso de scripts.
- fragmentos de codigo explicativo.
- apendice de terminos y siglas.

---

## 14. Recomendaciones especificas para la memoria

Sugerencias para la redaccion final:

- usa un lenguaje formal y claro.
- organiza cada seccion con encabezados claros.
- evita jergas informales.
- anade referencias a la estructura del repositorio y al enfoque modular.
- destaca el valor anadido del trabajo en equipo y la presentacion.
- incluye un apartado de metodologia y planificacion si quieres reforzar la parte academica.

---

## 15. Checklist para la memoria final

- [ ] Titulo y datos de portada completos.
- [ ] indice claro y completo.
- [ ] Resumen conciso.
- [ ] Introduccion con contexto y motivacion.
- [ ] Objetivos definidos.
- [ ] Estado del arte referenciado.
- [ ] Metodologia documentada.
- [ ] Desarrollo tecnico explicado.
- [ ] Pruebas y validacion registradas.
- [ ] Resultados y conclusiones presentes.
- [ ] Bibliografia incluida.
- [ ] Anexos utiles.

---

## Notas finales

Esta guia es orientativa: adapta cada seccion al contenido real del proyecto y a la documentacion que tengais preparada. Usa la estructura para que la memoria sea legible, coherente y refleje tanto el trabajo tecnico como el trabajo organizativo del TFG.
