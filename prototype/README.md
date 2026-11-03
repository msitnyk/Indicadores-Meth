# Prototipo — Radar departamental de prácticas METH

**Iteración 3:** 2026-11-03 · conserva los datos evaluados de la instantánea anterior.  
**Concepto:** departamento → capacidad → ver en paralelo dos proyectos / ficha individual → indicadores y acciones.  
**Abrir:** doble clic en `index.html`. El HTML es autocontenido; no requiere instalación, servidor ni Internet. Los scripts de preparación son solo para mantenimiento.

## Ajustes de esta iteración

1. FedPat **PNC y PC se excluyen de la demo**, sin borrar ni modificar sus hojas Excel.
2. Se incorporan **Galicia, Santander y Master Bapro**, sin fuente ni evaluaciones. No son proyectos con puntaje cero. El listado queda con **12 proyectos: nueve evaluados y tres pendientes**.
3. Las tres capacidades departamentales muestran **gráficos de torta**: cumplimiento frente al porcentaje restante de la escala. No es una distribución de semáforos ni una medida de tareas completadas.
4. Desde una capacidad se pueden seleccionar **exactamente dos proyectos** para contrastar sus indicadores, alineados por criterio e identificador, en el mismo mes.
5. Se agrega exportación de la **vista actual** mediante el diálogo de impresión del navegador: elegir **Guardar como PDF**. No depende de un servicio remoto ni descarga un PDF automáticamente.
6. La métrica principal de acciones es ahora **cantidad de acciones activas del proyecto**, independientemente de las sugerencias de asociación con indicadores. Las sugerencias múltiples siguen disponibles, pero no se presentan como cobertura real de capacidades o alertas.

## Fidelidad y diseño

- **Visual: media:** interfaz utilitaria para presentar y recibir feedback; no es identidad corporativa validada.
- **Contenido: alto para los archivos existentes:** nueve fuentes de indicadores y doce acciones conservadas. Los tres proyectos nuevos están explícitamente pendientes.
- **Interacción: alta en el recorrido principal:** filtros, vista en paralelo, exportación de vista y estados/vínculos simulados; no hay autenticación ni persistencia.

Registro de producto interno, CSS y JavaScript vanilla; tokens en `:root`. Sin CDN, bibliotecas, red o almacenamiento local. Un único archivo HTML para quienes presentan o reciben la demo.

## Pantallas y flujo

| Ruta | Pantalla | Acción principal | Se llega desde |
|---|---|---|---|
| `#panorama` | Capacidades departamentales con tortas y lista de proyectos | Abrir una capacidad | Entrada y navegación |
| `#capacidad` | Criterios agregados y aportes de proyectos | Seleccionar dos para ver en paralelo o abrir una ficha | Tarjeta macro |
| `#comparacion` | Dos proyectos con indicadores alineados | Identificar diferencias, sin mezclar meses | Selección de dos proyectos en capacidad |
| `#proyecto` | Ficha individual, rúbrica, fuente y acciones del proyecto | Revisar indicadores y acciones | Listados y navegación |
| `#acciones` | Todos los Action Items y editor local | Revisar sugerencias o simular estados y vínculos | Ficha, vista en paralelo y navegación |
| `#metodo` | Reglas y procedencia | Contrastar cálculos y supuestos | Navegación |

La vista en paralelo y la ficha muestran ausencias como **Sin evaluación**. Los estados sin selección, sin coincidencias, mes vacío, indicador N/A y proyecto pendiente están contemplados. La selección de un tercer proyecto no reemplaza otro silenciosamente. Si un alcance excluye un proyecto seleccionado, no se mantiene una vista en paralelo oculta fuera de ese alcance.

## Cómo interpretar las métricas

### Semáforos y gráficos

- Indicador: `puntaje / máximo × 100`; únicamente números válidos dentro de escala.
- Criterio y capacidad de proyecto: promedio directo de porcentajes de sus indicadores válidos.
- Global de proyecto: promedio de las tres capacidades, solo si las tres tienen evaluaciones válidas.
- Macro departamental por capacidad: promedio de esa capacidad entre proyectos válidos, con igual peso por proyecto. Los tres pendientes se ven en cobertura, pero no se convierten en cero ni entran al promedio.
- Verde ≥80 %, amarillo ≥50 % y <80 %, rojo <50 %, aplicado antes de redondear. Umbrales y ponderación provisionales.
- La torta ilustra ese porcentaje y `100 − porcentaje`. No significa cantidad de prácticas verdes ni trabajo pendiente. Cuando no hay evaluación, el gráfico queda gris y no representa 0 %.
- Los datos numéricos de la iteración 2 se preservan: septiembre sigue dando **56,6 % / 76,2 % / 49,1 %**, ahora con **9/12** proyectos aportantes.
- Mes y cuenta cambian el macro. Búsqueda/color de la tabla y filtros de vista en paralelo no cambian los resultados agregados.

### Acciones activas versus sugerencias

- Son activas **New, To Do y Doing**; Done y Cancelled se conservan sin contarse como activas.
- La cantidad se calcula por proyecto identificado en el archivo o vinculado explícitamente en la demo. **No requiere indicador, criterio ni capacidad confirmados.**
- Un mismo item se cuenta una vez por proyecto, aunque tenga múltiples sugerencias de indicadores.
- En la fuente actual: **MARS tiene 1 activa, Medifé 4 y RIG 3**. El archivo tiene **10 activas en total**, de las cuales **2 siguen sin proyecto identificado**. No se asignan por suposición a FluxIT ni a los nuevos proyectos.
- El nombre de origen permite proponer la correspondencia MARS/Portal de prestadores/Website Redesign; se mantiene visible que esa correspondencia requiere revisión. La cantidad de acciones de un proyecto no prueba que cubran una capacidad o indicador determinado.
- Las sugerencias pueden ser múltiples. Por ejemplo, #39272 sugiere indicadores 17 y 10; #39777 sugiere 2 y 3. No se duplican los items por estos vínculos.
- Los estados de acciones son la instantánea actual del archivo, **no** un histórico de lo que estaba vigente en el mes evaluado.
- Cambiar un estado modifica el contador en la demo, **no el puntaje**. La simulación no crea acciones ni modifica Excel o Redmine. Recargar o restablecer descarta los cambios.

## Vista en paralelo de dos proyectos

1. Abrir una tarjeta de capacidad.
2. Marcar dos proyectos en sus aportes.
3. Elegir **Ver en paralelo**.
4. Revisar el mismo criterio/indicador lado a lado, con sus puntajes, estados y ausencias.
5. Cambiar el mes o filtrar desvíos. El filtro considera los indicadores en alerta de cualquiera de los dos proyectos, sin borrar su contraparte ni recalcular el promedio.

Es válido ver en paralelo un proyecto evaluado con uno pendiente: la columna pendiente mantiene **Sin evaluación**, no puntuaciones inventadas. La vista no demuestra causalidad ni califica un proyecto como mejor sin considerar aplicabilidad y contexto.

## Exportar a PDF

- Usar **Exportar vista a PDF** y elegir **Guardar como PDF** en el diálogo del navegador.
- Se prepara una versión de lectura de la vista activa con título, mes, alcance, fuente y advertencias. La vista en paralelo conserva ambos proyectos.
- Los detalles necesarios del informe se expanden en la copia de impresión; no se cambia la navegación original.
- Los controles de edición no se imprimen. Si hay estados simulados, no deben confundirse con actualizaciones de la fuente.
- El archivo no se guarda hasta que la persona confirma destino/nombre en el diálogo. Cancelar no genera PDF ni se presenta como exportación exitosa.
- Puede ser necesario ajustar orientación/escala en el diálogo según la vista y el navegador. La exportación no publica ni envía el informe.

## Fuentes y mantenimiento

- `../overview.md`: hallazgos y decisiones acumulados por iteración.
- `data-snapshot.json`: instantánea de datos y roster de la demo; `generatedAt` refleja el armado de esta iteración, no una actualización de los tickets.
- `extraction-report.md`: registro histórico de extracción del 2026-11-02; los datos evaluados y las acciones originales no cambian en esta iteración.
- `extract-data.ps1`: generador actualizado para el nuevo roster, sin modificar XLSX. Su ejecución sigue sujeta a la política del entorno.
- `build-prototype.cjs`: validación e inyección segura del JSON dentro del HTML, idempotente.
- `verify-prototype.cjs` y `verify-real-data.cjs`: verificaciones sin dependencias.

Para mantenimiento, desde la raíz:

```powershell
node prototype/build-prototype.cjs
node prototype/verify-prototype.cjs
node prototype/verify-real-data.cjs
```

La reextracción con `.\prototype\extract-data.ps1` está documentada como bloqueada por la política PowerShell del entorno. No se cambió esa política ni se recomienda eludirla. La instantánea existente y Node permiten preparar/verificar el HTML sin esa reextracción. Quien abre `index.html` no necesita ejecutar comandos.

## Guion para probar con METH

1. Abrir septiembre: comprobar las tortas y que un proyecto pendiente no baje artificialmente el promedio.
2. Entrar a capacidad 1, seleccionar CRM y MARS y ver en paralelo indicadores del mismo criterio.
3. Intentar un tercer proyecto; comprobar que no se pierde una selección sin aviso.
4. Ver en paralelo MARS y Galicia: revisar si queda claro que Galicia no tiene evaluación.
5. Abrir MARS: ver una acción activa aunque sus sugerencias de indicadores no estén confirmadas.
6. Revisar una sugerencia múltiple sin duplicar el contador; simular Done y comprobar que cambia la cantidad, no la práctica.
7. Exportar la vista en paralelo a PDF y elegir destino en el diálogo. Recoger feedback sobre legibilidad, evidencia y próximos pasos.

---

## ⚠️ Supuestos y pendientes

- Los meses textuales no tienen año confirmado; el consolidado es **nominal y provisional**, no una medición temporal formal.
- Se usa provisionalmente el nombre homónimo de cuenta para Galicia, Santander y Master Bapro; no se dispone de fuente ni detalle de proyecto para ellos.
- Ponderación igual por proyecto, umbrales e indicadores críticos requieren validación departamental.
- Los orígenes RR - SDLC asistido con IA y Run Run 5 continúan sin correspondencia inequívoca con los proyectos evaluados.
- Cantidad de acciones activas no demuestra cobertura ni efectividad del plan; asociaciones múltiples siguen siendo sugerencias.
- Permisos, alojamiento, persistencia, actualización y decisión Excel versus evaluación web siguen fuera de alcance.
- No se hicieron entrevistas ni validación formal de diseño. El prototipo es una ayuda para pensar, no un producto terminado.

**Privacidad:** contiene evaluaciones, responsables y acciones reales. Compartir HTML y PDF solo con personas autorizadas.

## Verificación de la iteración 3

La validación actualizada se registra en `validation-results.md`. El roster fue comprobado contra la versión Git anterior: las nueve fuentes evaluadas, el catálogo y las doce acciones permanecen idénticos; únicamente se reemplazaron los dos proyectos excluidos por los tres pendientes y se actualizaron las advertencias. Los resultados de pruebas de la iteración 2 no se consideran prueba automática de las nuevas funciones. Para esta iteración pasan **31 pruebas de estructura/modelo y 14 sobre datos reales**, incluidas 180 combinaciones proyecto–capacidad–mes. El navegador verificó el recorrido, la vista en paralelo y las copias de impresión; se revisaron capturas de escritorio. La validación automatizada no guarda un PDF ni reemplaza la revisión de su paginación por quien exporta.
