# Guía para la memoria del TFG

Este archivo es una plantilla de guía para redactar la memoria final del Trabajo Fin de Grado (TFG). Está pensada para el proyecto de automatización de configuración, seguridad y software por departamentos, adaptada al ecosistema desarrollado en el repo.

---

## 1. Portada

Incluye:

- Título del proyecto.
- Autor/es.
- Tutores.
- Titulación: ASIR.
- Curso académico.
- Centro educativo.

---

## 2. Índice

Lista de secciones con números de página. Incluye:

- Resumen
- Introducción
- Objetivos
- Estado del arte
- Metodología
- Desarrollo del proyecto
- Pruebas y validación
- Resultados
- Conclusiones
- Bibliografía
- Anexos

---

## 3. Resumen (abstract)

- Breve descripción del proyecto.
- Objetivos principales.
- Método de trabajo.
- Resultados más relevantes.
- Conclusión o aporte principal.

El resumen debe ser conciso y comprenderse sin leer el resto del documento.

---

## 4. Introducción

Explica:

- Contexto del proyecto.
- Motivación para elegirlo.
- Importancia de automatizar configuraciones y seguridad.
- Relación con el mundo profesional y académico.
- Alcance general del TFG.

---

## 5. Objetivos

Detalla los objetivos generales y específicos:

- Objetivo general: crear un sistema automatizado de configuración y despliegue por departamentos.
- Objetivos específicos:
  - modularizar scripts por función y departamento
  - diseñar un menú de selección intuitivo
  - garantizar seguridad básica y estandarización
  - documentar el proceso y presentar la solución

Incluye criterios de éxito y alcance real del proyecto.

---

## 6. Estado del arte

Describe:

- referencias y proyectos similares.
- herramientas existentes para automatización en entornos empresariales.
- buenas prácticas en gestión de configuración y hardening.
- comparación breve con la solución del TFG.

Puede incluir:

- PowerShell para Windows
- scripts de despliegue y configuración
- estructura modular de proyectos

---

## 7. Metodología

Explica el proceso de trabajo:

- planificación y organización del proyecto.
- fases del desarrollo.
- herramientas usadas: GitHub, VS Code, PowerShell, etc.
- trabajo en equipo y coordinación.
- criterios para tomar decisiones de diseño.

Incluye un diagrama de fases si quieres.

---

## 8. Desarrollo del proyecto

Presenta la implementación en detalle:

- estructura del repositorio y razones de diseño.
- descripción de los módulos principales:
  - `modulos/configuracion basica/`
  - `modulos/seguridad/`
  - `modulos/software/`
  - `modulos/opciones_dpt.ps1`
- lógica por departamentos y cómo se aplica.
- explicación del flujo de ejecución.
- decisiones de organización y nombres.

Es importante justificar la arquitectura y mostrar ejemplos concretos.

---

## 9. Pruebas y validación

Incluye:

- cómo se probó cada módulo.
- escenarios de uso por departamento.
- verificación de cambios de configuración.
- pruebas de seguridad básicas.
- resultados de ejecución y logs generados.

Si no se pudo ejecutar en un entorno real, explica las limitaciones y las pruebas realizadas en entorno de desarrollo.

---

## 10. Resultados

Resume los resultados obtenidos:

- qué se ha conseguido automatizar.
- mejoras esperadas en tiempos de despliegue.
- la organización amplia del proyecto.
- qué queda pendiente o qué se puede ampliar.

Incluye una valoración objetiva sobre el cumplimiento de los objetivos.

---

## 11. Conclusiones

Reflexiona sobre:

- lecciones aprendidas.
- fortalezas del proyecto.
- debilidades o aspectos a mejorar.
- utilidad real del proyecto para el entorno objetivo.
- dirección futura (mejoras, ampliaciones, integración con más departamentos o herramientas).

---

## 12. Bibliografía

Lista las fuentes consultadas:

- documentación técnica de PowerShell.
- guías de hardening.
- ejemplos de automatización.
- artículos y repositorios usados como referencia.

Usa un estilo de cita claro (APA breve, IEEE, etc.).

---

## 13. Anexos

Añade material adicional útil:

- capturas de pantalla del proyecto o de menús si es necesario.
- listas de software o configuraciones de ejemplo.
- ejemplos de uso de scripts.
- fragmentos de código explicativo.
- apéndice de términos y siglas.

---

## 14. Recomendaciones específicas para la memoria

Sugerencias para la redacción final:

- usa un lenguaje formal y claro.
- organiza cada sección con encabezados claros.
- evita jergas informales.
- añade referencias a la estructura del repositorio y al enfoque modular.
- destaca el valor añadido del trabajo en equipo y la presentación.
- incluye un apartado de metodología y planificación si quieres reforzar la parte académica.

---

## 15. Checklist para la memoria final

- [ ] Título y datos de portada completos.
- [ ] Índice claro y completo.
- [ ] Resumen conciso.
- [ ] Introducción con contexto y motivación.
- [ ] Objetivos definidos.
- [ ] Estado del arte referenciado.
- [ ] Metodología documentada.
- [ ] Desarrollo técnico explicado.
- [ ] Pruebas y validación registradas.
- [ ] Resultados y conclusiones presentes.
- [ ] Bibliografía incluida.
- [ ] Anexos útiles.

---

## Notas finales

Esta guía es orientativa: adapta cada sección al contenido real del proyecto y a la documentación que tengáis preparada. Usa la estructura para que la memoria sea legible, coherente y refleje tanto el trabajo técnico como el trabajo organizativo del TFG.
