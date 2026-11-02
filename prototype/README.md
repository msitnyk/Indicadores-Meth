# Prototipo — Radar departamental de prácticas METH

**Concepto:** Departamento → capacidad → proyecto → criterio → indicador → acción existente.  
**Iteración 2:** 2026-11-02 · primer piloto FedPat: 2026-10-30.  
**Abrir:** doble clic en `index.html`. El HTML entregado contiene los datos; no necesita instalación, servidor ni Internet. No es una aplicación publicada ni sincroniza archivos o tickets.

## Qué cambia respecto del piloto

- La entrada muestra **primero las tres capacidades a nivel departamental**, con aportes de todas las cuentas disponibles.
- Cada tarjeta lleva a la capacidad: criterios agregados, aportes por proyecto y ausencias.
- La ficha mantiene el detalle de capacidades, criterios, indicadores, rúbrica y celda fuente.
- Se incorpora el archivo de Action Items: candidatos por indicador, estado y responsable de fuente; confirmación manual de vínculos y cambio de estado **simulados**.
- Las hojas sin año explícito no se asignan silenciosamente a 2026: los consolidados son **cortes por mes nominal**, pendientes de normalización temporal.

## Fidelidad

- **Visual: media** — presentación utilitaria para una demo, sin adoptar identidad corporativa inexistente. Distribución y textos provisionales.
- **Contenido: alto para los archivos disponibles** — instantánea de las hojas METH nuevas y del archivo de acciones; relaciones semánticas señaladas como sugeridas, nunca como hechos confirmados.
- **Interacción: alta en el recorrido principal** — filtros, navegación macro/micro, vínculos y estados en memoria; sin autenticación, edición de puntuaciones ni persistencia.

**Registro:** producto interno. CSS y JavaScript vanilla, tokens en `:root`, sin CDN, frameworks ni dependencias de red.

## Pantallas y flujo

| Ruta | Pantalla | Acción principal | Se llega desde |
|---|---|---|---|
| `#panorama` | Tres capacidades departamentales y tabla de proyectos | Abrir una capacidad | Entrada, navegación, retornos |
| `#capacidad` | Criterios agregados y aportes por proyecto | Abrir un proyecto manteniendo la capacidad seleccionada | Tarjeta macro, navegación |
| `#proyecto` | Ficha, criterio, indicador y acciones candidatas | Revisar o vincular una acción existente | Tabla de panorama/aportes |
| `#acciones` | Todos los items y editor de simulación | Confirmar vínculo, asociar manualmente o simular estado | Indicador, navegación |
| `#metodo` | Reglas, fuentes y advertencias | Verificar cálculo y procedencia | Navegación |

Estados alternativos: selección pendiente; búsqueda sin coincidencias; proyecto sin modelo nuevo; mes sin evaluación; indicador N/A; vínculo sugerido; acción sin proyecto identificado; acción inactiva; confirmación de cambios locales. No se presenta importación exitosa/error de carga porque la importación interactiva está fuera del recorrido prototipado.

## Reglas y decisiones de diseño

1. **Indicador:** puntaje / máximo. Solo números válidos dentro de escala. `0` se conserva; vacío, N/A y error no se convierten en cero.
2. **Criterio y capacidad de proyecto:** promedio directo de porcentajes de indicadores válidos.
3. **Global de proyecto:** promedio de tres capacidades con igual peso, solo si las tres tienen datos válidos.
4. **Macro departamental por capacidad:** promedio de esa capacidad entre proyectos evaluados del mismo mes nominal; cada proyecto tiene igual peso. **No** se pondera por cuenta, tamaño, criticidad ni cantidad de indicadores aplicables. Dos proyectos de FedPat aportan dos votos; una cuenta con un proyecto aporta uno.
5. **Cobertura:** proyectos que aportan / total de proyectos del alcance. Los ausentes siguen visibles y fuera del promedio, nunca se imputan en cero.
6. Los filtros de mes y cuenta cambian el alcance macro. La búsqueda y el color en la tabla solo reducen la tabla, no sesgan el semáforo departamental.
7. Los umbrales son provisionales: verde ≥80 %, amarillo ≥50 % y <80 %, rojo <50 %. El color se asigna antes de redondear.
8. La cobertura de acciones solo considera indicadores amarillos/rojos con un vínculo **confirmado** y acción en estado **New, To Do o Doing**. Done y Cancelled quedan visibles pero no cubren alertas. Un item puede cubrir varios indicadores, sin duplicarse en el conteo de acciones únicas.

## Acciones: qué se simula y qué no

- Las asociaciones iniciales se basan en títulos, nombres y notas de las fuentes; todas se muestran como **sugeridas**. Una semejanza no es una relación formal indicador–acción.
- Se puede revisar un candidato y confirmar el vínculo por botón, o seleccionar explícitamente un proyecto e indicador para vincular un item existente.
- Se puede retirar un vínculo o simular el estado de una acción. Las puntuaciones no se modifican.
- **No se disparan acciones automáticamente**, no se crean tickets y no se modifican Excel ni Redmine.
- Cada cambio muestra confirmación de simulación; recargar o «Restablecer fuente» descarta las modificaciones.
- «Sin acción activa confirmada» expresa la falta de cobertura validada en la instantánea y la demo: **no demuestra que no exista un plan** fuera de ella.
- El archivo contiene estados actuales de acciones. **No reconstruye qué acción estaba vigente en el mes evaluado.**

## Fuentes y reproducción

- `../overview.md`: resultados y decisiones del piloto, más la ampliación departamental.
- `data-snapshot.json`: extracción trazable, valores brutos y fuentes por fila/columna; el HTML incorpora una copia autocontenida.
- `extract-data.ps1`: extracción offline de XLSX por ZIP/XML, sin modificar archivos fuente.
- `build-prototype.cjs`: valida e incrusta la instantánea en el HTML, escapando contenido de celdas de forma segura; se puede ejecutar repetidamente.
- `verify-prototype.cjs`: pruebas de cálculo y estructura con fixtures aislados, sin datos inventados en la demo.
- `extraction-report.md`: evidencia de extracción y advertencias.

Para quien mantiene la demo, desde la carpeta raíz:

```powershell
.\prototype\extract-data.ps1
node prototype/build-prototype.cjs
node prototype/verify-prototype.cjs
node prototype/verify-real-data.cjs
```

Estos comandos son para mantener la instantánea; **quien presenta o recibe `index.html` no los necesita**. En este entorno, el comando `extract-data.ps1` está actualmente bloqueado por la política de ejecución de PowerShell (`PSSecurityException`): no se cambió ni se recomienda eludirla. El `data-snapshot.json` ya extraído está incorporado en el HTML, y la construcción y verificación con Node funcionan. Si la organización autoriza ejecutar el extractor, podrá renovarse la instantánea; no existen carga web ni sincronización automática.

## Trazabilidad y guion de prueba

- **Panorama:** responde a «cómo estamos como departamento en las tres capacidades».
- **Capacidad:** permite localizar qué proyectos explican el agregado, preservando ausencias.
- **Proyecto:** convierte un color en un criterio e indicador específicos con fuente verificable.
- **Acciones:** conecta la brecha con una posible intervención existente, manteniendo revisión humana.
- **Método:** distingue medición, propuesta de ponderación, período incierto y vínculos pendientes.

Guion de 10 minutos:

1. Abrir el departamento en septiembre: pedir que identifiquen una capacidad para profundizar.
2. Abrir esa capacidad y comparar proyectos; preguntar si el peso igual por proyecto refleja el interés del departamento.
3. Abrir FedPat → MARS → Gestión de Deuda Técnica. Revisar el candidato de acción y confirmar su vínculo **solo en la demo**.
4. Simular la acción como Done: comprobar que deja de cubrir la alerta y que el puntaje no se vuelve verde por cerrar un ticket.
5. Revisar Medifé → Gestión de Dependencias y Bloqueos: comprobar que una acción Cancelled no se presenta como plan activo.
6. Buscar una acción cuyo proyecto no esté identificado y preguntar a qué proyecto debe asociarse.
7. Preguntar qué evidencia, responsable o seguimiento falta para decidir una acción. No preguntar solamente «¿te gusta?».

---

## ⚠️ Alerta de supuestos

No hay entrevistas ni validación de diseño formal: este prototipo parte de la conversación y los archivos disponibles. Es una ayuda para pensar; las reacciones son evidencia para la siguiente iteración, no aprobación de producto.

Pendientes de validar:

- Año de las cabeceras mensuales sin fecha; alcance histórico y comparación interanual. Las fechas completas se conservan como evidencia, pero el agregado de la demo sigue siendo nominal.
- Peso igual por proyecto frente a peso por cuenta, criticidad u otra regla departamental.
- Umbrales y excepciones para indicadores críticos.
- Asociaciones sugeridas de proyectos y de indicadores; especialmente orígenes de acciones que no aparecen inequívocamente en las planillas.
- Diferencia entre N/A, falta de evaluación e inexistencia de fuente nueva en la aplicación futura.
- Gobierno de datos, permisos, alojamiento, actualización y decisión Excel versus evaluación dentro de la web.
- La interfaz y el texto explicativo son propuestas. Los puntajes y los datos de acciones provienen de los archivos; no se inventan cuentas ni URLs de tickets.

**Privacidad:** contiene evaluaciones reales, nombres de responsables y acciones. Compartir el HTML únicamente con personas autorizadas.

## Verificación

- `node prototype/verify-prototype.cjs`: **23 PASS** de estructura, cálculos, cobertura, estados, vínculos e inyección segura, con fixtures aislados.
- `node prototype/verify-real-data.cjs`: **11 PASS** sobre la instantánea real, incluyendo **165** combinaciones proyecto–capacidad–mes y mantenimiento de los resultados del piloto FedPat.
- **690 valores brutos mensuales** extraídos y verificados; 207 filas de indicador, 12 acciones. Los hashes de los XLSX se conservaron. Ver `extraction-report.md` para procedencia y límites de reextracción.
- Recorrido probado en el DOM del navegador: tres tarjetas macro, filtros sin sesgar el agregado, aportes, ficha, filtro de rojos, evolución mensual, revisión de candidatos, confirmación explícita, estado simulado, vínculo manual y restablecimiento.
- Recuperación de foco al quitar contexto corregida; rutas y contraste de colores verificados. No es una auditoría exhaustiva de accesibilidad.
- La ventana del navegador no estaba visible para capturas y clics por coordenadas: esas operaciones no pudieron completarse. Se probaron los controles mediante eventos DOM; queda pendiente la revisión visual/puntero y la prueba en dispositivo móvil físico.
- No se modificó Excel, no se publicó la web y no se confirmó ninguna relación en las fuentes. Las mutaciones de prueba se restablecieron.
