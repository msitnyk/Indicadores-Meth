# Verificación del prototipo — Iteración 2 · 2026-11-02

**Resultado técnico: PASS en cálculos, estructura y recorrido DOM probado.** No equivale a validación de uso, revisión visual completa ni producto listo para publicar.

| Verificación | Resultado |
|---|---|
| `node prototype/build-prototype.cjs` | HTML preparado con 11 proyectos, 12 acciones; 120.235 bytes. |
| `node prototype/verify-prototype.cjs` | 23 PASS: estructura, tokens, rutas, inyección segura, promedios, cobertura, vínculos y estados. |
| `node prototype/verify-real-data.cjs` | 11 PASS: instantánea, 165 combinaciones proyecto/capacidad/mes, reglas y acciones reales. |
| Fuentes | 9 hashes SHA-256 de XLSX coinciden con el informe de extracción; ningún archivo fuente modificado. |
| Navegador DOM | 20 comprobaciones PASS sobre filtros, navegación, ficha, evolución, acciones y confirmación explícita. |
| Router accesible | Cinco rutas: una pantalla visible, foco en encabezado y `aria-current` correcto. |
| Contraste de texto | Siete pares principales ≥4,5:1, mínimo observado 5,59:1; no auditoría exhaustiva de accesibilidad. |
| Fuente y simulación | Links iniciales restaurados como sugeridos; ninguna modificación de Excel/Redmine. |
| Sintaxis del extractor | Parser PowerShell: 0 errores, sin ejecutar ni alterar política. |

## Recorrido DOM verificado

- Panorama: tres capacidades, once proyectos, cobertura nueve de once en septiembre.
- Búsqueda sin coincidencias no cambia el agregado. Alcance por cuenta sí cambia el macro.
- Noviembre vacío no arrastra septiembre ni genera verdes.
- Tarjeta de capacidad → criterios agregados y once aportes → MARS con capacidad destacada.
- Ficha: tres capacidades, ocho criterios, cuatro rojos de MARS al filtrar, promedio sin alteración y cinco meses visibles.
- Acción #39883: abrir candidato no confirma; confirmar sí aumenta cobertura; elegir estado sin guardar no cambia nada; simular Done elimina cobertura, manteniendo el puntaje.
- Lista de doce acciones conserva orígenes sin correspondencia. Vínculo manual requiere botón; no cambia el origen de fuente.
- Restablecer recupera estados y sugerencias originales. Al quitar contexto se recupera foco visible; se corrigió un defecto encontrado en revisión.
- Acción Cancelled #39270 permanece visible sin cobertura, comprobada también en las pruebas sobre datos reales.

## Limitaciones y bloqueos

1. La ventana del navegador no estaba visible: screenshot y clic mediante coordenadas fallaron. No se insistió ni se alteró la seguridad. Se comprobó el DOM con eventos programáticos, sin afirmar prueba de puntero ni revisión visual completa. Pendiente dispositivo móvil físico.
2. Años de meses textuales no confirmados: el consolidado es nominal/provisional.
3. Relaciones acción–indicador sugeridas y orígenes RR/Run Run sin resolver; no se confirman automáticamente.
4. Reextracción mediante `extract-data.ps1` bloqueada por política PowerShell (`PSSecurityException`). No se modificó la política. Los valores extraídos previamente y la construcción/verificación del HTML con Node sí funcionan.
5. No hay publicación, permisos, persistencia, edición de puntuaciones ni integración real de tickets. Los cambios de acciones son una demostración local.
