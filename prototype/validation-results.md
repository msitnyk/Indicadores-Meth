# Verificación del prototipo — Iteración 3 · 2026-11-03

**Resultado técnico: PASS** en estructura, reglas, datos reales, comparación y preparación de impresión. No equivale a validación de uso ni aplicación lista para publicar.

| Verificación | Resultado |
|---|---|
| Preparación del HTML | 12 proyectos y 12 acciones incrustados; 138.596 bytes. Abre offline sin scripts auxiliares. |
| `node prototype/verify-prototype.cjs` | **31 PASS**: reglas, cantidad de acciones, comparación, tortas, PDF, estructura e inyección segura. |
| `node prototype/verify-real-data.cjs` | **14 PASS**: roster, datos reales, 180 combinaciones proyecto–capacidad–mes y conservación del piloto. |
| Recorrido de navegador | **18 comprobaciones DOM PASS** de nuevas funciones; prueba final adicional de seis rutas, PDF limpio, controles, estado restaurado y ancho de página. |
| Fuentes | Nueve hashes SHA-256 de XLSX sin diferencias. Catálogo, nueve proyectos evaluados y doce acciones idénticos a Git HEAD anterior. |
| Revisión visual | Capturas de escritorio del panorama y comparación CRM/MARS; selección real mediante casillas y botón de comparar probada. |
| PDF | Copia de la vista activa probada, sin controles ni IDs duplicados; mantiene gráficos, proyectos, mes y advertencias. |
| Extractor | Sintaxis PowerShell válida sin ejecutar ni alterar política. Generador actualizado para el nuevo roster. |

## Red → Green observado

- Se actualizó primero la prueba del roster: falló con **8 !== 11** cuentas representadas antes de modificar la instantánea.
- Las pruebas de funciones nuevas fallaron con **`m.projectActions is not a function`** antes de implementarlas.
- Tras la implementación e inyección, las 45 pruebas de los dos verificadores pasan, incluida la regresión de textos «Ver en paralelo».
- Una comprobación DOM del PDF de acciones se ajustó para sincronizar la ruta antes de clonar y comparar textos sin dependencia de mayúsculas; luego confirmó doce items con estados fuente/demo.

## Comportamientos comprobados

- PNC/PC ausentes del roster de la demo, sin cambiar el Excel.
- Galicia, Santander y Master Bapro sin fuente ni puntajes; nueve proyectos aportan al macro de doce representados.
- Tortas con dos sectores de cumplimiento/restante. Geometrías 0 %, 100 % y ausencia válidas; ausencia no genera 0 %.
- Cantidad activa por proyecto sin vínculo confirmado: MARS 1, Medifé 4, RIG 3. Archivo: diez activas, dos sin proyecto identificado.
- Una acción con varias sugerencias se cuenta una vez. Done/Cancelled no cuentan como activas. Simular un estado no modifica el puntaje.
- Selección de exactamente dos proyectos, tercer intento rechazado sin reemplazar, foco conservado y poda por alcance.
- CRM/MARS alineados en los nueve indicadores de capacidad 1; los filtros usan la unión de alertas y no recalculan promedios.
- Comparación con un proyecto pendiente y cambio de mes conservan «Sin evaluación», sin arrastre.
- PDF del panorama conserva tres gráficos y nombres de proyectos. PDF comparativo conserva ambos proyectos y nueve filas; copia expandida sin abrir los detalles originales.
- PDF de acciones conserva doce items y estados de fuente versus simulación, sin formularios de edición.
- Se retiraron comandos de navegación de la copia imprimible, conservando etiquetas reales de proyectos.
- Las simulaciones fueron restablecidas; fuente y puntuaciones permanecen inmutables.

## Límites y pendientes

1. **PDF nativo:** se comprobó la preparación del informe y la invocación de impresión con `window.print` sustituido por un contador durante la automatización. No se afirma un PDF guardado ni se verificó exhaustivamente su paginación. La persona debe elegir **Guardar como PDF**, nombre y destino en el diálogo del navegador.
2. **Móvil:** adaptación CSS presente; no se probó en dispositivo físico.
3. **Período:** años de meses textuales aún no confirmados; macro nominal/provisional.
4. **Acciones:** cantidad no demuestra cobertura ni efectividad; correspondencias por nombre y sugerencias múltiples requieren revisión. RR y Run Run 5 siguen pendientes.
5. **Extracción:** política PowerShell bloquea la ejecución estándar del extractor; no se cambió. La instantánea mantenida y la preparación/verificación con Node funcionan.
6. **Producto:** sin publicación, autenticación, persistencia, creación real de tickets ni modificación de evaluaciones. No se agregaron dependencias ni se realizaron commits.
