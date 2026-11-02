# Evidencia de extracción XLSX — 2026-11-02

Reproducir desde la raíz: `& .\prototype\extract-data.ps1`. Si la política de ejecución impide scripts, informar el bloqueo sin modificarla. PowerShell ZIP/XML y .NET, sin Python, módulos externos ni Excel instalado. Lee archivos en modo ZIP read-only. Salida UTF-8 sin BOM. Fecha de snapshot fijada por contrato; no es una fecha inferida de los datos.

## Validaciones y cobertura

- 8 cuentas; 9 fuentes nuevas seleccionadas exclusivamente por F1=Indicador; 23 indicadores por fuente (207 filas). 11 proyectos representados: 9 con METH NUEVO y FedPat PNC/PC sin fuente nueva. Catálogo: 3 capacidades, 8 criterios, 23 indicadores. Primera fuente CHUB define el catálogo; las diferencias semánticas se advierten, no se normalizan silenciosamente.
- 12 acciones (filas 2–13, incluida 39777); 0 URLs inventadas. Relaciones proposed/suggested, nunca confirmed. RR/Run Run quedan sin proyecto asociado.
- values sólo contiene meses presentes en cabecera. Números reales (Double.Parse/TryParse InvariantCulture), N/A literal, vacío null; no forward-fill, no cero imputado. Columnas sin mes no entran en cálculos; M/Jorge de MARS se excluye íntegramente.
- El agregado mensual es provisional por mes calendario, no un histórico interanual fiable: sólo RIG y TecPlata tienen año confirmado por fechas seriales. Los demás NO tienen año confirmado, incluso si el filename menciona un año.

| Proyecto | Meses / columna / fecha confirmada | Numéricos | N/A | Vacíos | Cobertura numérica sobre celdas con mes |
|---|---|---:|---:|---:|---:|
| CHUB · CHUB | 07/J/año desconocido; 08/K/año desconocido; 09/L/año desconocido | 54 | 15 | 0 | 78.26% |
| FedPat · CRM | 07/J/año desconocido; 08/K/año desconocido; 09/L/año desconocido | 69 | 0 | 0 | 100.00% |
| FedPat · MARS | 07/J/año desconocido; 08/K/año desconocido; 09/L/año desconocido | 68 | 1 | 0 | 98.55% |
| Fertisa · Fertisa | 07/J/año desconocido; 08/K/año desconocido; 09/L/año desconocido; 10/M/año desconocido | 44 | 25 | 23 | 47.83% |
| FluxIT · FluxIT | 07/J/año desconocido; 08/K/año desconocido; 09/L/año desconocido | 69 | 0 | 0 | 100.00% |
| Medifé · Portal de prestadores | 07/J/año desconocido; 08/K/año desconocido; 09/L/año desconocido; 10/M/año desconocido | 88 | 4 | 0 | 95.65% |
| RIG · Website Redesign | 07/O/2026-07-01; 08/P/2026-08-01; 09/Q/2026-09-01 | 69 | 0 | 0 | 100.00% |
| TecPlata · L3 | 09/J/2026-09-01; 10/K/2026-10-02 | 46 | 0 | 0 | 100.00% |
| Tenpo · Migración de Cuenta | 07/J/año desconocido; 08/K/año desconocido; 09/L/año desconocido; 10/M/año desconocido; 11/N/año desconocido | 60 | 9 | 46 | 52.17% |
| FedPat · PNC | sin METH NUEVO | 0 | 0 | 0 | sin fuente |
| FedPat · PC | sin METH NUEVO | 0 | 0 | 0 | sin fuente |

Total de celdas con cabecera de mes: 690; numéricas: 567; N/A: 54; vacías: 69. Sobre universo fijo 9 fuentes × 23 indicadores × 5 meses = 1035 celdas, los meses sin columna representan 345 celdas no disponibles, no valores null observados. PNC/PC quedan fuera de este denominador por ausencia de fuente nueva.

### Cobertura por mes calendario

| Mes | Fuentes con cabecera | Fuentes con algún número | Numéricos | N/A | Vacíos observados | Celdas sin columna (de 207) |
|---|---:|---:|---:|---:|---:|---:|
| Julio (07) | 8 | 8 | 158 | 26 | 0 | 23 |
| Agosto (08) | 8 | 8 | 171 | 13 | 0 | 23 |
| Septiembre (09) | 9 | 9 | 193 | 14 | 0 | 0 |
| Octubre (10) | 4 | 2 | 45 | 1 | 46 | 115 |
| Noviembre (11) | 1 | 0 | 0 | 0 | 23 | 184 |

## Septiembre: capacidad por proyecto y departamental

Por proyecto/capacidad: 100 × promedio simple de (puntaje / máximo) de cada indicador numérico válido; cada indicador tiene el mismo peso. NO es suma de puntajes / suma de máximos. N/A, null y meses ausentes se excluyen, sin imputación. Cobertura: filas numéricas / total de indicadores de capacidad. Macro de proyecto: promedio simple de sus tres capacidades, sólo cuando las tres tienen datos válidos. Departamental por capacidad: promedio simple de porcentajes de proyectos válidos (peso igual proyecto; sin ausentes). Macro departamental: promedio simple de las macros de proyectos válidos. Los cálculos usan precisión completa; sólo la presentación se redondea.

| Proyecto | C1 % (cobertura) | C2 % (cobertura) | C3 % (cobertura) | Macro % |
|---|---:|---:|---:|---:|
| CHUB · CHUB | 62.50% (8/9) | 75.00% (8/10) | 41.67% (4/4) | 59.72% |
| FedPat · CRM | 18.52% (9/9) | 56.67% (10/10) | 25.00% (4/4) | 33.40% |
| FedPat · MARS | 57.41% (9/9) | 86.67% (10/10) | 62.50% (4/4) | 68.86% |
| Fertisa · Fertisa | 45.24% (7/9) | 91.67% (6/10) | 54.17% (4/4) | 63.69% |
| FluxIT · FluxIT | 64.81% (9/9) | 75.00% (10/10) | 50.00% (4/4) | 63.27% |
| Medifé · Portal de prestadores | 40.74% (9/9) | 47.92% (8/10) | 41.67% (4/4) | 43.44% |
| RIG · Website Redesign | 70.37% (9/9) | 83.33% (10/10) | 62.50% (4/4) | 72.07% |
| TecPlata · L3 | 64.81% (9/9) | 73.33% (10/10) | 50.00% (4/4) | 62.72% |
| Tenpo · Migración de Cuenta | 85.42% (8/9) | 95.83% (8/10) | 54.17% (4/4) | 78.47% |
| FedPat · PNC | sin datos | sin datos | sin datos | sin datos |
| FedPat · PC | sin datos | sin datos | sin datos | sin datos |
| **Departamental (peso igual proyecto válido)** | **56.65%** (9 proyectos) | **76.16%** (9 proyectos) | **49.07%** (9 proyectos) | **60.63%** (9 proyectos) |

Septiembre: 193/207 puntajes numéricos (93.24%), 14 N/A y 0 vacíos. Año confirmado sólo en RIG y TecPlata. Los porcentajes son de madurez relativa al máximo aplicable, no promedios sobre escala fija 3.

### Verificación de la corrección de métricas

- CRM, sin redondear para cálculos: C1 = 18.5185185185%, C2 = 56.6666666667%, C3 = 25%; macro = 33.3950617284%.
- Departamental: C1 = 56.6468253968%, C2 = 76.1574074074%, C3 = 49.0740740741%; macro = 60.6261022928%.
- Todas las filas de capacidad, cobertura y macro del informe se comprobaron con Node sobre el snapshot existente; dos cálculos independientes repetidos producen resultados idénticos. La sintaxis PowerShell se validó sin ejecutar el script.
- Snapshot sin modificaciones, SHA-256 `CEEC5B406ABE70453B6DA37CF6C773529B7F2ED505DE31D69B7DD4EE5F291A96`. Los hashes actuales de los 9 XLSX coinciden con los registrados en Procedencia de archivos.
- **Reextracción PowerShell bloqueada:** el comando estándar `& .\prototype\extract-data.ps1` devuelve `PSSecurityException` porque la ejecución de scripts está deshabilitada. No se modificó la política. No se afirma una reextracción exitosa ni su determinismo con la nueva fórmula; sí se verificó el determinismo del cálculo de métricas y se actualizó el generador para reproducir la tabla cuando la ejecución esté permitida.

## Lista completa de acciones

| ID / fila | Proyecto fuente → propuesta | Estado | Prioridad | Asunto | Responsable | Inicio | Actualizado (sin TZ) | Indicadores sugeridos | URL |
|---|---|---|---|---|---|---|---|---|---|
| 39883 / 2 | MARS - Gobernanza → fedpat-mars (suggested) | To Do | Normal | Gestionar activamente la deuda técnica de los repositorios | Diego Vitulli | 2026-10-21 | 2026-10-21 14:39 | 18 | null |
| 39274 / 3 | Portal de Prestadores - Gobernanza → medife-portal (suggested) | New | Normal | Deuda técnica de  Infraestructura y Configuración | sin asignar | 2026-09-07 | 2026-09-07 15:06 | 18 | null |
| 39273 / 4 | Portal de Prestadores - Gobernanza → medife-portal (suggested) | Doing | Normal | Clasificar y cuantificar bugs | Romina Perez | 2026-09-07 | 2026-10-16 10:34 | 16 | null |
| 39272 / 5 | Portal de Prestadores - Gobernanza → medife-portal (suggested) | To Do | Normal | Acordar y escribir DoR y DoD | Romina Perez | 2026-09-07 | 2026-10-16 10:35 | 17, 10 | null |
| 39271 / 6 | Portal de Prestadores - Gobernanza → medife-portal (suggested) | New | Normal | Obtener KPIs Nexo | Romina Perez | 2026-09-07 | 2026-10-01 11:52 | 8 | null |
| 39270 / 7 | Portal de Prestadores - Gobernanza → medife-portal (suggested) | Cancelled | Normal | Mapa de dependencias | Romina Perez | 2026-09-07 | 2026-10-28 09:17 | 12 | null |
| 40077 / 8 | RR - SDLC asistido con IA - Gobernanza → sin proyecto inequívoco | New | Normal | Porcentaje del alcance/hitos comprometidos para la cadencia acordada | Evangelina Okabe | 2026-10-30 | 2026-10-30 17:57 |  | null |
| 40075 / 9 | RR - SDLC asistido con IA - Gobernanza → sin proyecto inequívoco | New | High | Socializar semanalmente con lideres la planificación y la visión a largo plazo | Evangelina Okabe | 2026-10-30 | 2026-10-30 17:57 |  | null |
| 39224 / 10 | Run Run 5 - Gobernanza → sin proyecto inequívoco | Done | Normal | Project Report / Indicadores: 2 Ejecución con calidad y previsibilidad / 2.3	Confiabilidad y Calidad Operativa: Rigor del Definition of Done | Laura Mauro | 2026-09-03 | 2026-09-15 16:32 |  | null |
| 39779 / 11 | website-redesign-gobernanza → rig-website (suggested) | New | Normal | Encuestas de Clima / Seguridad Psicologica | Juan Suárez | 2026-10-09 | 2026-10-09 12:39 | 22 | null |
| 39778 / 12 | website-redesign-gobernanza → rig-website (suggested) | New | Normal | Establecer proceso de retros formales | Juan Suárez | 2026-10-09 | 2026-10-09 12:37 | 21 | null |
| 39777 / 13 | website-redesign-gobernanza → rig-website (suggested) | New | Normal | Indicadores - Salud del backlog + Priorización por Impacto y ROI - Evaluar Sumar BA en 2027 para mejorar en este punto | sin asignar | 2026-10-09 | 2026-10-09 12:31 | 2, 3 | null |

### Evidencia de RIG (hoja antigua, sólo para sugerir proyecto)
- D12: https://redmine.app.fluxitsoft.com/projects/rig-website-redesign/issues
- D2: RIG | Website Redesign R-M-01 Minuta de Kickoff interno v1.3

## Anomalías y advertencias
- [period] chub: Los encabezados de mes son texto: año desconocido. No se infiere del nombre del archivo. Agregado por mes calendario provisional; no es un histórico interanual fiable.
- [period] fedpat-crm: Los encabezados de mes son texto: año desconocido. No se infiere del nombre del archivo. Agregado por mes calendario provisional; no es un histórico interanual fiable.
- [period] fedpat-mars: Los encabezados de mes son texto: año desconocido. No se infiere del nombre del archivo. Agregado por mes calendario provisional; no es un histórico interanual fiable.
- [source] fedpat-mars: Se excluye la columna M (Jorge): no representa un mes y sus puntuaciones no se incorporan ni se usan como notas.
- [period] fertisa: Los encabezados de mes son texto: año desconocido. No se infiere del nombre del archivo. Agregado por mes calendario provisional; no es un histórico interanual fiable.
- [source] fertisa: El mes 10 tiene cabecera en M pero los 23 valores están vacíos (null); no se arrastran datos de otro mes.
- [period] fluxit: Los encabezados de mes son texto: año desconocido. No se infiere del nombre del archivo. Agregado por mes calendario provisional; no es un histórico interanual fiable.
- [period] medife-portal: Los encabezados de mes son texto: año desconocido. No se infiere del nombre del archivo. Agregado por mes calendario provisional; no es un histórico interanual fiable.
- [period] tecplata-l3: El encabezado K1 es el serial 46297.0, fecha 2026-10-02 (no 1 de octubre); se agrupa por mes calendario 10 preservando la fecha.
- [period] tenpo-migracion: Los encabezados de mes son texto: año desconocido. No se infiere del nombre del archivo. Agregado por mes calendario provisional; no es un histórico interanual fiable.
- [source] tenpo-migracion: El mes 10 tiene cabecera en M pero los 23 valores están vacíos (null); no se arrastran datos de otro mes.
- [source] tenpo-migracion: El mes 11 tiene cabecera en N pero los 23 valores están vacíos (null); no se arrastran datos de otro mes.
- [source] fedpat-pnc: No existe hoja METH NUEVO con F1=Indicador para este proyecto. Se conserva sin filas, sin puntajes y sin arrastrar el METH anterior.
- [source] fedpat-pc: No existe hoja METH NUEVO con F1=Indicador para este proyecto. Se conserva sin filas, sin puntajes y sin arrastrar el METH anterior.
- [mapping] Acción 40077 / RR - SDLC asistido con IA - Gobernanza: no hay proyecto inequívoco en los XLSX; projectId=null, links=[], sin asumir FluxIT.
- [mapping] Acción 40075 / RR - SDLC asistido con IA - Gobernanza: no hay proyecto inequívoco en los XLSX; projectId=null, links=[], sin asumir FluxIT.
- [mapping] Acción 39224 / Run Run 5 - Gobernanza: no hay proyecto inequívoco en los XLSX; projectId=null, links=[], sin asumir FluxIT.
- [mapping] Todas las relaciones acción-proyecto e indicador son inferencias propuestas (suggested), por confirmar. website-redesign se sugiere para RIG por evidencia del Meth antiguo, sin usar sus puntajes.
- [source] El XLSX de acciones no contiene URLs explícitas ni relaciones hyperlink externas: las 12 acciones conservan url=null. No se inventan enlaces Redmine a partir del ID.

## Procedencia de archivos

- `CHUB - Nuevos indicadores_ Template Master.xlsx` SHA-256 `532AD8C70A3E70E75897568222C02347118B14D4C226ED2A1841BDE0557E4C64`
- `FedPat - Indicadores Prácticas 2026.xlsx` SHA-256 `8AE664D12A3281DBBE6B8643CCB4D3D71CDC2172742D7204A794DD7EE103E0D0`
- `Fertisa - Nuevos indicadores_ Template Master.xlsx` SHA-256 `CF47DFB5F95A5F439FD03795E6E7BF3381D291B1ACDF638025465F59910678D3`
- `FluxIT - Indicadores Prácticas Vigente Junio 2025.xlsx` SHA-256 `A4587355806ADF3FAD9CEE82E83BDBFCB9F3A26192C93FDD037509BED3FCF85D`
- `Medife-Portal de prestadores - Indicadores Prácticas 2026-2027.xlsx` SHA-256 `B17B6220FE3EF0FB986DDD2ABF1C85670E5176263411E8627D242816EF672F30`
- `Retro METH (análisis de indicadores DL-PL) -_ Action Items.xlsx` SHA-256 `66ADAFBEE234A25DA19AB63871F2D9C97CD39CADF65B8380EB76AC9DF4D3F77B`
- `RIG - Indicadores Prácticas 2025 - 2026.xlsx` SHA-256 `09D5B29DC570F75E3A0A1218DEC606549A3DBE1495D326F45605AECD0D43F4E0`
- `TecPlata L3 - Indicadores Prácticas 2026 - 2027.xlsx` SHA-256 `AB181F8662FC17D09FB7254744CD8EDFD6E99A2D22E9DAAFDAF23893540A8D97`
- `Tenpo - Migración de Cuenta _ Indicadores Prácticas.xlsx` SHA-256 `8B0386ED575B615D0F66BFD7363C7A2C8189BA32D0FB009BADFF50231242156C`
