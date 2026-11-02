# Overview — Semáforo de prácticas METH

Este documento conserva los hallazgos del piloto FedPat y acumula las decisiones de la ampliación departamental. La [demo actual](prototype/index.html) incorpora el recorrido macro → micro y las acciones; las tablas iniciales corresponden a la primera iteración, no al consolidado de todas las cuentas.

## Iteración 1 · Piloto FedPat

### Objetivo y alcance

Unificar los indicadores **METH nuevos** por cuenta, proyecto, período e indicador para identificar brechas y decidir acciones. Este piloto lee **un solo archivo**, `FedPat - Indicadores Prácticas 2026.xlsx`; el alcance futuro sigue siendo **todas las cuentas** de la carpeta, incluidas CHUB y Fertisa. Se preparó una [demo navegable local](prototype/index.html) de este piloto (sin backend, publicación ni sincronización); no se modificó el Excel.

En FedPat, las hojas `CRM Meth - Nuevo` y `MARS Meth - Nuevo` contienen 23 indicadores cada una (filas 2–24), distribuidos en tres capacidades: alineación estratégica (9), ejecución con calidad (10) e inteligencia operativa (4). Las hojas `PNC Meth`, `PC Meth`, `CRM Meth`, `MARS Meth` y `Meth` tienen el formato anterior (`Nombre`, `Aspecto`, `Cómo se mide`, `Estado`): **no se usan** para este semáforo. PNC y PC quedan **sin fuente nueva identificada en este archivo**, no en rojo ni en cero.

## Regla propuesta para probar

- Para cada indicador: **cumplimiento = puntaje / escala máxima** (columnas `J`–`L` frente a `I`). Se conserva el `0` explícito como puntaje válido.
- 🟢 **Verde:** ≥80 %; 🟡 **amarillo:** ≥50 % y <80 %; 🔴 **rojo:** <50 %; ⚪ **sin dato:** vacío, `N/A`, error o puntaje inválido. Los umbrales son **provisionales**, sujetos a validación de METH.
- Resultado de capacidad: promedio simple de los porcentajes de sus indicadores evaluados. Resultado global de proyecto: promedio simple de las **tres capacidades**, cada una con el mismo peso. También se muestran cobertura y cantidad de rojos: el promedio nunca reemplaza el detalle.
- `Julio`, `Agosto` y `Septiembre` se leen como períodos, pero **el año no figura en esas cabeceras**; *2026* se infiere solo del nombre del archivo y debe confirmarse antes de combinar históricos. En `MARS Meth - Nuevo`, la columna `M` dice **«Jorge»**: aunque contiene puntajes, **no se interpreta como otro mes**.

## Vista piloto: septiembre (año por confirmar)

| Proyecto | Cobertura | Verdes | Amarillos | Rojos | Alineación estratégica | Ejecución y calidad | Inteligencia operativa | Global¹ |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| CRM | 23/23 | 2 | 8 | 13 | 🔴 18,5 % | 🟡 56,7 % | 🔴 25,0 % | 🔴 **33,4 %** |
| MARS | 23/23 | 10 | 9 | 4 | 🟡 57,4 % | 🟢 86,7 % | 🟡 62,5 % | 🟡 **68,9 %** |

¹ Promedio de los porcentajes por capacidad, con igual peso entre las tres; no es el promedio directo de los 23 indicadores.

### Desglose del semáforo por capacidad

El color de cada capacidad se calcula a partir del **promedio simple de sus indicadores**, no de la cantidad de indicadores verdes. La columna `🟢/🟡/🔴` muestra cuántos indicadores componen ese resultado y permite ver alertas ocultas por el promedio.

| Capacidad | Indicadores | CRM: estado y cumplimiento | CRM 🟢/🟡/🔴 | MARS: estado y cumplimiento | MARS 🟢/🟡/🔴 |
|---|---:|---:|---:|---:|---:|
| 1. Alineación estratégica y de valor del delivery | 9 | 🔴 18,5 % | 0/0/9 | 🟡 57,4 % | 2/5/2 |
| 2. Ejecución con calidad y previsibilidad | 10 | 🟡 56,7 % | 1/8/1 | 🟢 86,7 % | 7/2/1 |
| 3. Inteligencia operativa y mejora continua | 4 | 🔴 25,0 % | 1/0/3 | 🟡 62,5 % | 1/2/1 |

### Desglose del semáforo por criterio

Cada criterio es el **promedio simple de los porcentajes de sus indicadores evaluados**; una capacidad promedia **directamente sus indicadores**, no los porcentajes de sus criterios (porque los criterios pueden tener diferente cantidad de indicadores). En septiembre, la cobertura de cada criterio es completa para ambos proyectos.

| Capacidad | Criterio | Indicadores (IDs) | CRM: estado y cumplimiento | CRM 🟢/🟡/🔴 | MARS: estado y cumplimiento | MARS 🟢/🟡/🔴 |
|---|---|---|---:|---:|---:|---:|
| 1. Alineación estratégica | **1.1** Madurez y Gestión del Backlog | 1–3 | 🔴 22,2 % | 0/0/3 | 🟡 61,1 % | 0/3/0 |
| 1. Alineación estratégica | **1.2** Planificación Evolutiva y Feedback | 4–6 | 🔴 22,2 % | 0/0/3 | 🟢 88,9 % | 2/1/0 |
| 1. Alineación estratégica | **1.3** Cultura de Producto e Impacto | 7–9 | 🔴 11,1 % | 0/0/3 | 🔴 22,2 % | 0/1/2 |
| 2. Ejecución y calidad | **2.1** Previsibilidad del Flujo y Compromisos | 10–12 | 🔴 38,9 % | 0/2/1 | 🟢 100,0 % | 3/0/0 |
| 2. Ejecución y calidad | **2.2** Liderazgo Preventivo y Relación | 13–15 | 🟡 66,7 % | 1/2/0 | 🟢 100,0 % | 3/0/0 |
| 2. Ejecución y calidad | **2.3** Confiabilidad y Calidad Operativa | 16–19 | 🟡 62,5 % | 0/4/0 | 🟡 66,7 % | 1/2/1 |
| 3. Inteligencia operativa | **3.1** Inspección, Métricas y Mejora | 20–21 | 🔴 0,0 % | 0/0/2 | 🔴 41,7 % | 0/1/1 |
| 3. Inteligencia operativa | **3.2** Sostenibilidad y Personas | 22–23 | 🟡 50,0 % | 1/0/1 | 🟢 83,3 % | 1/1/0 |

**Lectura para decidir:** `1.3 Cultura de Producto e Impacto` y `3.1 Inspección, Métricas y Mejora` quedan rojos en **ambos** proyectos. En CRM, `2.1 Previsibilidad del Flujo y Compromisos` también queda rojo, aunque la capacidad 2 en conjunto sea amarilla; en MARS, la capacidad 2 es verde, pero `2.3 Confiabilidad y Calidad Operativa` conserva un indicador rojo. Son señales para conversar con los equipos, no diagnósticos de causa.

### Semáforo por indicador, septiembre

| Nº | Indicador | Máximo | CRM | MARS |
|---:|---|---:|---|---|
| 1 | Alineación con Objetivos de Negocio | 3 | 🔴 1/3 | 🟡 2/3 |
| 2 | Salud del Backlog | 3 | 🔴 1/3 | 🟡 2/3 |
| 3 | Priorización por Impacto y ROI | 2 | 🔴 0/2 | 🟡 1/2 |
| 4 | Evolución del plan de entregas | 3 | 🔴 1/3 | 🟢 3/3 |
| 5 | Transparencia de la estrategia | 3 | 🔴 0/3 | 🟢 3/3 |
| 6 | Accionabilidad del Feedback del Cliente | 3 | 🔴 1/3 | 🟡 2/3 |
| 7 | Entendimiento del Propósito | 3 | 🔴 1/3 | 🟡 2/3 |
| 8 | Tracción de Métricas de Negocio | 2 | 🔴 0/2 | 🔴 0/2 |
| 9 | Validación de Impacto Post-Lanzamiento | 3 | 🔴 0/3 | 🔴 0/3 |
| 10 | Cumplimiento del Compromiso | 3 | 🟡 2/3 | 🟢 3/3 |
| 11 | Control de Cambios de Alcance | 2 | 🔴 0/2 | 🟢 2/2 |
| 12 | Gestión de Dependencias y Bloqueos | 2 | 🟡 1/2 | 🟢 2/2 |
| 13 | Gestión Preventiva de Riesgos | 2 | 🟡 1/2 | 🟢 2/2 |
| 14 | Sinergia de la Tríada | 2 | 🟢 2/2 | 🟢 2/2 |
| 15 | Satisfacción y Relación con el Cliente | 2 | 🟡 1/2 | 🟢 2/2 |
| 16 | Tasa de Escape de Defectos | 3 | 🟡 2/3 | 🟡 2/3 |
| 17 | Rigor del Definition of Done | 2 | 🟡 1/2 | 🟢 2/2 |
| 18 | Gestión de Deuda Técnica | 3 | 🟡 2/3 | 🔴 1/3 |
| 19 | Estrategia y Cobertura de Testing | 3 | 🟡 2/3 | 🟡 2/3 |
| 20 | Uso Operativo de Métricas de Flujo | 2 | 🔴 0/2 | 🟡 1/2 |
| 21 | Efectividad de las Retrospectivas | 3 | 🔴 0/3 | 🔴 1/3 |
| 22 | Clima y Seguridad Psicológica | 3 | 🔴 0/3 | 🟡 2/3 |
| 23 | Desarrollo y Desempeño Individual | 2 | 🟢 2/2 | 🟢 2/2 |

## Evolución y primeros insights

| Proyecto | Mes | Evaluados | 🟢 | 🟡 | 🔴 | Promedio directo de indicadores² |
|---|---|---:|---:|---:|---:|---:|
| CRM | Julio | 23/23 | 2 | 11 | 10 | 44,9 % |
| CRM | Agosto | 23/23 | 2 | 8 | 13 | 36,2 % |
| CRM | Septiembre | 23/23 | 2 | 8 | 13 | 36,2 % |
| MARS | Julio | 22/23 | 7 | 10 | 5 | 62,9 % |
| MARS | Agosto | 23/23 | 8 | 11 | 4 | 67,4 % |
| MARS | Septiembre | 23/23 | 10 | 9 | 4 | 71,0 % |

² Esta columna es solo para seguir la tendencia de los indicadores; **no** equivale al global de igual peso por capacidad de la primera tabla. En julio, `Gestión de Deuda Técnica` de MARS dice `N/A` y se excluye del promedio y de la cobertura, no se puntúa como cero.

- **CRM:** en septiembre, los **9 indicadores** de alineación estratégica están rojos. Para priorizar, revisar primero `Transparencia de la estrategia`, `Priorización por Impacto y ROI`, `Tracción de Métricas de Negocio` y `Validación de Impacto Post-Lanzamiento` (todos con puntaje 0). El semáforo detecta la brecha, **no demuestra su causa**.
- **MARS:** mejora de 62,9 % a 71,0 % en el promedio directo de indicadores de julio a septiembre, pero mantiene 4 rojos en septiembre. Dos son compartidos con CRM: `Tracción de Métricas de Negocio` y `Validación de Impacto Post-Lanzamiento`; podrían ser una oportunidad de acción transversal, previa validación de contexto.
- **Calidad del dato:** la columna `Jorge` con puntajes en MARS necesita definición (¿evaluación alternativa, escenario, responsable?). No debe incorporarse al histórico por una suposición. Los `N/A` y las ausencias de hojas nuevas deben quedar visibles en la futura vista.

## Decisiones por validar antes de escalar

1. Confirmar si julio–septiembre corresponden a **2026** y qué representa `Jorge` en MARS.
2. Confirmar los umbrales 80 % / 50 %, el peso igual por capacidad y si algún indicador requiere nivel máximo o criticidad especial para considerarse verde.
3. Resolver cómo representar proyectos que solo tienen planilla METH anterior (PNC y PC): por ahora **«sin fuente nueva»**, nunca cero.
4. Validar con referentes de cada proyecto las hipótesis de acción; los puntajes señalan dónde investigar, no explican por qué ocurre la brecha.

**Fuente trazable:** `FedPat - Indicadores Prácticas 2026.xlsx` → `CRM Meth - Nuevo` y `MARS Meth - Nuevo`, filas 2–24, columnas `A`–`B` (identificador y nombre de capacidad), `C`–`D` (identificador y nombre de criterio), `E` (identificador de indicador), `F` (indicador), `I` (escala máxima), `J` (julio), `K` (agosto) y `L` (septiembre). Esta es una lectura de los valores guardados en el archivo, no un recálculo de fórmulas de Excel.

## Iteración 2 · Departamento, capacidades y acciones — 2026-11-02

### Nuevo recorrido

**Departamento → capacidad → proyecto → criterio → indicador → acción existente.** La [demo actual](prototype/index.html) muestra primero las tres capacidades consolidadas. Al abrir una, se ven sus criterios departamentales y los aportes de cada proyecto; desde allí se entra a la ficha individual.

Se incorporaron **8 cuentas**, **9 proyectos con modelo nuevo** y **12 Action Items**. FedPat PNC y PC siguen visibles sin fuente nueva: son **11 proyectos representados**, pero no se inventan puntuaciones para esos dos.

### Semáforo departamental provisional · septiembre

| Capacidad | Cumplimiento | Semáforo | Proyectos que aportan / representados | Indicadores válidos / del modelo nuevo |
|---|---:|---|---:|---:|
| 1. Alineación estratégica y de valor del delivery | **56,6 %** | 🟡 Amarillo | 9/11 | 77/81 |
| 2. Ejecución con calidad y previsibilidad | **76,2 %** | 🟡 Amarillo | 9/11 | 80/90 |
| 3. Inteligencia operativa y mejora continua | **49,1 %** | 🔴 Rojo | 9/11 | 36/36 |

**Regla propuesta:** cada capacidad departamental es el promedio simple del porcentaje de esa capacidad en cada proyecto evaluado. Dentro del proyecto, cada indicador válido tiene igual peso (`promedio de puntaje/máximo`); **no** se usa `suma de puntajes/suma de máximos`. Cada proyecto aporta un voto, por lo que FedPat con CRM y MARS aporta dos; no se pondera aún por cuenta, tamaño o criticidad.

**Limitación temporal importante:** el corte agrupa por mes nominal. RIG y TecPlata tienen fechas completas de 2026; las otras hojas solo nombran el mes. No se infiere el año desde el nombre del archivo. Este consolidado sirve para la demo, **no debe presentarse como una medición histórica departamental definitiva** hasta confirmar los años.

### Aportes por proyecto · septiembre

| Cuenta / proyecto | Capacidad 1 | Capacidad 2 | Capacidad 3 |
|---|---:|---:|---:|
| CHUB | 🟡 62,5 % | 🟡 75,0 % | 🔴 41,7 % |
| FedPat · CRM | 🔴 18,5 % | 🟡 56,7 % | 🔴 25,0 % |
| FedPat · MARS | 🟡 57,4 % | 🟢 86,7 % | 🟡 62,5 % |
| Fertisa | 🔴 45,2 % | 🟢 91,7 % | 🟡 54,2 % |
| FluxIT | 🟡 64,8 % | 🟡 75,0 % | 🟡 50,0 % |
| Medifé · Portal de prestadores | 🔴 40,7 % | 🔴 47,9 % | 🔴 41,7 % |
| RIG · Website Redesign | 🟡 70,4 % | 🟢 83,3 % | 🟡 62,5 % |
| TecPlata · L3 | 🟡 64,8 % | 🟡 73,3 % | 🟡 50,0 % |
| Tenpo · Migración de Cuenta | 🟢 85,4 % | 🟢 95,8 % | 🟡 54,2 % |
| FedPat · PNC / PC | ⚪ Sin fuente nueva | ⚪ Sin fuente nueva | ⚪ Sin fuente nueva |

### Vinculación de acciones

El archivo `Retro METH (análisis de indicadores DL-PL) -_ Action Items.xlsx` aporta ID, proyecto de origen, asunto, estado, prioridad, responsable y fechas. **No tiene una columna formal de indicador ni URLs explícitas de tickets.** Se mantienen los IDs reales y se abre el detalle local, sin fabricar enlaces externos.

Ejemplos de asociaciones **sugeridas, por confirmar**:

| Item | Proyecto propuesto | Indicador propuesto | Estado fuente | Consideración |
|---|---|---|---|---|
| #39883 · Gestionar activamente la deuda técnica de los repositorios | FedPat · MARS | Gestión de Deuda Técnica | To Do | Candidato para un indicador rojo en septiembre; no implica acción automáticamente disparada ni vínculo validado. |
| #39272 · Acordar y escribir DoR y DoD | Medifé · Portal de prestadores | Rigor del Definition of Done / Cumplimiento del Compromiso | To Do | Propuesta basada en asunto y notas de la planilla; revisar si realmente atiende ambos indicadores. |
| #39270 · Mapa de dependencias | Medifé · Portal de prestadores | Gestión de Dependencias y Bloqueos | Cancelled | Visible, pero no cuenta como acción activa aunque se confirme la relación. |
| #39779 · Encuestas de Clima / Seguridad Psicologica | RIG · Website Redesign | Clima y Seguridad Psicológica | New | Nombre de proyecto propuesto a partir de evidencia del archivo RIG; sin usar puntuaciones del modelo anterior. |

Todas las relaciones iniciales son `suggested`. La demo permite confirmar un vínculo, asociar manualmente otro indicador, desvincular o simular un estado. **Los cambios viven solo en memoria y no modifican Excel ni Redmine.** New, To Do y Doing cuentan como activos; Done y Cancelled no cubren alertas. El puntaje no cambia por cerrar una acción.

La cobertura validada comienza en cero hasta confirmar relaciones. **Esto no prueba que no haya acciones en curso**. Los estados de acciones son la instantánea actual del archivo, no un histórico de qué estaba vigente durante septiembre.

### Insights nuevos para el departamento

- **Capacidad 3:** queda en rojo en el agregado (49,1 %) y ninguno de los nueve proyectos alcanza verde en esa capacidad. Tiene 36/36 indicadores numéricos: la señal no se explica por falta de datos dentro de esta capacidad. Es una hipótesis de foco transversal, no un diagnóstico causal.
- **Alineación estratégica:** CRM, Fertisa y Medifé quedan en rojo; las acciones deberían analizarse con foco en sus criterios, no únicamente en el global del proyecto.
- **Medifé:** las tres capacidades quedan rojas en septiembre. Hay acciones candidatas, pero la de dependencias está cancelada: merece revisar si existe una iniciativa activa alternativa.
- **Aplicabilidad:** CHUB, Fertisa, Medifé y Tenpo tienen indicadores N/A. Se excluyen del promedio y se muestra cobertura para no comparar ciegamente porcentajes sobre conjuntos distintos.
- **Períodos recientes:** octubre solo tiene puntajes en Medifé y TecPlata; Fertisa y Tenpo tienen columnas de octubre vacías. Noviembre no tiene puntajes. La demo muestra ausencias, sin arrastrar septiembre.
- **Identidad de proyectos:** #40077 y #40075 (`RR - SDLC asistido con IA - Gobernanza`) y #39224 (`Run Run 5 - Gobernanza`) no tienen correspondencia inequívoca con un proyecto de estas planillas. Permanecen visibles, sin asignarlos a FluxIT ni a otra cuenta por suposición.

### Decisiones pendientes de esta iteración

1. Confirmar a qué cuenta/proyecto corresponden **RR - SDLC asistido con IA** y **Run Run 5**.
2. Confirmar los años de los meses textuales antes de interpretar el macro como una comparación temporal formal.
3. Validar **peso igual por proyecto** frente a peso por cuenta u otra regla departamental.
4. Revisar las relaciones acción–indicador sugeridas y la evidencia necesaria para considerarlas confirmadas.
5. Definir luego dónde se gestionan los datos, permisos y persistencia; el prototipo no cierra la decisión Excel versus carga web.

### Verificación y límites técnicos

Se validó la instantánea y el cálculo contra el modelo de la demo: 23 pruebas de estructura/reglas con fixtures y 11 pruebas sobre datos reales, incluidas 165 combinaciones proyecto–capacidad–mes. La extracción registró 690 valores brutos mensuales y conservación de los archivos XLSX, con evidencia en [extraction-report.md](prototype/extraction-report.md). Las pruebas DOM del navegador verifican el recorrido y las mutaciones simuladas; no sustituyen una prueba de uso con METH.

El HTML distribuido está preparado y abre sin instalación. **La reextracción mediante el script PowerShell está bloqueada por la política de ejecución del entorno**; no se modificó esa política. La instantánea ya generada y la reconstrucción/verificación con Node funcionan. Esto afecta la actualización técnica de datos, no la apertura del prototipo para presentar.
