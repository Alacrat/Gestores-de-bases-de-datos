# Normalización del modelo de una clínica veterinaria

## 1. Propósito

La normalización organiza los datos en relaciones con responsabilidades definidas. Su propósito es reducir las repeticiones innecesarias y evitar anomalías al insertar, actualizar o eliminar información.

En esta clínica veterinaria, el modelo distingue personas, mascotas, atención clínica, inventario y facturación. La separación permite, por ejemplo, actualizar los datos de una persona una sola vez aunque sea propietaria de mascotas y también trabaje en la clínica.

El esquema físico se implementa en **MySQL**, con 47 tablas, 228 columnas y 64 claves foráneas. Este documento explica sus dependencias y decisiones de organización. Las restricciones y vistas se encuentran en `vet_db.sql`.

## 2. Conceptos básicos

| Concepto | Significado | Ejemplo del modelo |
|---|---|---|
| Clave primaria | Identificador elegido para cada fila | `id_mascota` |
| Clave candidata | Conjunto mínimo de atributos que identifica una fila | `(id_tipo_documento, numero_documento)` en `persona` |
| Superclave | Conjunto que identifica una fila, aunque incluya atributos adicionales | `(id_cita, id_mascota)` en `cita` |
| Dependencia funcional | Un valor de X determina un único valor de Y | `id_raza → id_especie` |
| Dependencia parcial | Un atributo no primo depende de una parte de una clave candidata | Datos globales del producto dentro de una relación producto–sede |
| Dependencia transitiva | La clave determina un atributo a través de otro determinante | Una mascota determina su raza y esta determina su especie |
| Dependencia multivaluada | Un conjunto de valores de una entidad es independiente de otro | Teléfonos y correos de una persona |

Un atributo **primo** pertenece a alguna clave candidata. La notación `X → Y` representa una dependencia funcional y `X →→ Y`, una dependencia multivaluada.

Una columna `UNIQUE` que acepta `NULL` no es, por sí sola, una clave candidata de toda la relación en el sentido clásico. Por ejemplo, puede haber varias mascotas sin microchip y varias cuentas técnicas sin `id_veterinario`. La unicidad solo se aplica a los valores informados.

## 3. Primera forma normal: valores individuales

La primera forma normal (1FN) requiere valores individuales dentro de los dominios definidos, sin listas o grupos repetidos almacenados en una celda.

| Información | Representación |
|---|---|
| Teléfonos de una persona | Una fila por teléfono en `persona_telefono` |
| Correos de una persona | Una fila por correo en `persona_email` |
| Contactos de sedes y proveedores | Tablas independientes para teléfonos y correos |
| Especialidades de un profesional | Una fila por asociación en `veterinario_especialidad` |
| Principios activos de un medicamento | Una fila por asociación en `medicamento_principio_activo` |
| Dosis | `dosis_cantidad` y referencia a `unidad_medida` |

Una persona con tres teléfonos tiene tres filas de contacto. No es necesario agregar una columna nueva cada vez que registra otro número.

Separar dosis y unidad facilita cálculos, comparaciones y validaciones. La atomicidad depende del uso previsto: conservar una dirección como texto es válido cuando la aplicación la trata como una unidad. Asimismo, un texto que identifica un lote no incumple automáticamente 1FN; usar una clave foránea aporta integridad y trazabilidad.

## 4. Segunda forma normal: dependencia de la clave completa

La segunda forma normal (2FN) exige 1FN y que cada atributo no primo dependa de la totalidad de cada clave candidata, no de una parte de ella. Deben analizarse también las claves naturales: agregar un identificador automático no elimina por sí solo una dependencia parcial existente.

### Producto y sede

La identidad de un medicamento es global, pero su precio y su stock mínimo pueden variar por sede.

| Relación | Clave de negocio o determinante | Información propia |
|---|---|---|
| `medicamento` | `(nombre, id_laboratorio, id_presentacion)` | Identidad del producto y estado global |
| `medicamento_sede` | `(id_medicamento, id_sede)` | Precio, stock mínimo y estado en esa sede |
| `lote_medicamento` | `(id_medicamento_sede, numero_lote)` | Proveedor, vencimiento y cantidad del lote |

El nombre y la presentación no se repiten en cada sede. Las características comerciales locales dependen de la combinación completa producto–sede.

### Tablas con clave compuesta

En `persona_telefono`, la clave es `(id_persona, telefono)`. El indicador `es_principal` describe el uso de ese teléfono por esa persona. En las tablas puente de especialidades y principios activos, la clave compuesta identifica una asociación y no hay atributos descriptivos externos a ella.

## 5. Tercera forma normal: separación de dependencias

Una relación está en tercera forma normal (3FN) si, para toda dependencia funcional no trivial `X → A`, X es superclave o A es un atributo primo. En términos prácticos, los atributos descriptivos se ubican junto al hecho que los determina.

### 5.1 Raza y especie

```text
id_mascota → id_raza
id_raza → id_especie
```

`mascota` guarda `id_raza`; `raza` guarda `id_especie`. La especie se consulta mediante esa relación. Así, la identidad de la mascota no necesita repetir una clasificación ya determinada por su raza.

### 5.2 Ciudad y departamento

```text
id_sede → id_ciudad
id_ciudad → id_departamento
```

`sede` identifica la ciudad y `ciudad` identifica su departamento. La combinación `(id_departamento, nombre)` es única para permitir ciudades con el mismo nombre en departamentos diferentes.

### 5.3 Jaula y sede

```text
id_hospitalizacion → id_jaula
id_jaula → id_sede
```

La hospitalización obtiene su sede a través de la jaula. El número de jaula es único dentro de una sede, mediante `(id_sede, numero_jaula)`.

### 5.4 Datos personales

`persona` concentra documento, nombre, apellido y dirección. `propietario` guarda la fecha de registro y `veterinario` los atributos laborales. Ambas tablas apuntan a `persona` con una referencia obligatoria y única.

Esta organización es una generalización con subtipos que pueden coexistir. La persona no está obligada a pertenecer a ambos ni a alguno de ellos.

### 5.5 Catálogos

Los catálogos de roles, medios de pago, presentaciones, laboratorios y unidades proporcionan referencias consistentes. Crear un catálogo no demuestra por sí solo una violación previa de 3FN: también es una decisión de integridad de dominio y mantenimiento.

## 6. Relaciones opcionales y coherencia entre registros

Una atención puede existir sin cita y una hospitalización sin atención asociada. Por eso cada una conserva su referencia obligatoria a `mascota`.

| Relación compuesta | Coherencia que exige |
|---|---|
| `historia_clinica(id_cita, id_mascota)` con `cita` | La cita y la atención pertenecen a la misma mascota |
| `hospitalizacion(id_historia, id_mascota)` con `historia_clinica` | La atención de origen y la estancia pertenecen a la misma mascota |
| `recordatorio_vacunacion(id_vacunacion_cumplida, id_mascota, id_servicio)` con `vacunacion` | La aplicación que cumple el recordatorio corresponde a la mascota y servicio previstos |

Estas referencias mantienen coherencia en las asociaciones informadas. Los identificadores opcionales no deben presentarse como claves candidatas incondicionales, porque permiten múltiples valores nulos. La teoría clásica de normalización presupone relaciones sin marcadores nulos; el esquema físico necesita considerar expresamente esta diferencia.

El profesional asignado a una cita puede ser distinto del que realiza la atención. Del mismo modo, la sede de una cita puede ser distinta de la sede principal del profesional o de la mascota. Esas columnas representan hechos diferentes.

## 7. Cuarta forma normal: conjuntos independientes

Una relación está en cuarta forma normal (4FN) si, para toda dependencia multivaluada no trivial `X →→ Y`, X es superclave.

El modelo almacena por separado los conjuntos independientes:

| Entidad | Conjunto A | Conjunto B | Organización |
|---|---|---|---|
| Persona | Teléfonos | Correos | `persona_telefono` y `persona_email` |
| Medicamento | Principios activos | Sedes donde se maneja | `medicamento_principio_activo` y `medicamento_sede` |
| Personal | Especialidades | Bloques de horario | `veterinario_especialidad` y `horario_veterinario` |

Por ejemplo, una persona con tres teléfonos y dos correos necesita tres filas de teléfonos y dos filas de correos. No necesita seis filas que repitan todas las combinaciones entre ambos conjuntos.

Esta separación atiende las dependencias multivaluadas identificadas. Afirmar 4FN para cada relación exige, además, revisar sus dependencias funcionales y las reglas de negocio completas.

## 8. BCNF y quinta forma normal

### Forma normal de Boyce-Codd

BCNF exige que todo determinante de una dependencia funcional no trivial sea superclave. Se analiza cada relación y todas sus claves candidatas, no solo la clave primaria.

| Relación | Claves candidatas no nulas identificadas |
|---|---|
| `persona` | `id_persona`; `(id_tipo_documento, numero_documento)` |
| `propietario` | `id_propietario`; `id_persona` |
| `veterinario` | `id_veterinario`; `id_persona` |
| `usuario` | `id_usuario`; `nombre_usuario` |
| `ciudad` | `id_ciudad`; `(id_departamento, nombre)` |
| `raza` | `id_raza`; `(id_especie, nombre)` |
| `medicamento` | `id_medicamento`; `(nombre, id_laboratorio, id_presentacion)` |
| `medicamento_sede` | `id_medicamento_sede`; `(id_medicamento, id_sede)` |
| `lote_medicamento` | `id_lote`; `(id_medicamento_sede, numero_lote)` |
| `jaula` | `id_jaula`; `(id_sede, numero_jaula)` |

La combinación `(id_cita, id_mascota)` es una superclave de `cita`, pero no una clave candidata: `id_cita` por sí solo ya identifica la fila. El índice compuesto respalda la clave foránea que comprueba la mascota.

### Quinta forma normal

La quinta forma normal (5FN) exige que toda dependencia de reunión no trivial esté implicada por las claves candidatas. Se refiere a descomposiciones que permiten reconstruir exactamente los hechos, sin perder información ni crear combinaciones falsas.

Una cita es un evento concreto. Conocer por separado que una mascota ha sido atendida por un profesional y que ese profesional presta un servicio no demuestra que exista una cita específica entre ellos. Descomponer ese hecho en parejas sin conservar su identidad puede inventar asociaciones.

La ausencia de tablas ternarias formadas solo por claves no demuestra 5FN. Tampoco la demuestra el número de tablas. Es necesario especificar las dependencias de reunión del negocio y analizar cada relación. Este proyecto no atribuye una certificación global de 5FN al esquema físico.

## 9. Datos calculados y redundancias deliberadas

### Vistas de datos derivados

| Información | Origen | Consulta |
|---|---|---|
| Último peso conocido | Atenciones con peso no nulo | `v_peso_actual_mascota` |
| Estado de recordatorio | Cumplimiento y fecha próxima | `v_estado_recordatorio` |
| Existencias vigentes | Cantidades y vencimientos de lotes | `v_stock_medicamento_sede` |
| Subtotal de línea | Cantidad por precio histórico | `v_detalle_factura_subtotal` |
| Estado de hospitalización | Fecha y tipo de salida | `v_hospitalizacion_estado` |

Las vistas no descuentan inventario ni crean eventos. Solo consultan los registros existentes y calculan sus resultados al usarse.

### Facturación

La factura almacena subtotal, impuestos y total. La dependencia `(subtotal, impuestos) → total` tiene un determinante que no es superclave y un atributo dependiente no primo. Es una redundancia deliberada, incompatible con atribuir 3FN o BCNF estricta a esa relación.

El precio histórico pertenece a la línea facturada y puede diferir del precio vigente del catálogo. Guardar ese precio representa un hecho histórico propio. Por sí solo no exige duplicar el subtotal ni garantiza la inmutabilidad de la factura.

La consistencia entre cabecera, líneas y pagos requiere el proceso transaccional de la aplicación. El `CHECK` de la cabecera valida la suma de sus importes, pero no consulta otras tablas.

### Discriminador en subtipos de detalle

`detalle_factura_servicio` conserva un `tipo_item` constante igual a `servicio`, y `detalle_factura_medicamento` uno igual a `medicamento`. Ese dato participa en la clave foránea compuesta para garantizar que el subtipo coincida con la línea principal.

Es una redundancia física deliberada. Una constante no aporta información independiente; bajo el análisis clásico corresponde a una dependencia desde el conjunto vacío. No debe usarse este diseño para afirmar BCNF estricta en los subtipos.

Las restricciones garantizan **como máximo un subtipo compatible** por línea. Exigir que toda línea tenga uno corresponde a la transacción que registra la factura.

## 10. Resultado del diseño

La estructura concentra cada hecho en una relación adecuada: datos personales en `persona`, especie en `raza`, configuración comercial en `medicamento_sede` y cantidades de inventario en `lote_medicamento`. Los contactos y las asociaciones N:M tienen tablas propias.

El modelo aplica principios de normalización para las dependencias identificadas y conserva algunas redundancias para expresar reglas de integridad y registros de facturación. Su calidad se evalúa mediante las dependencias de cada relación, las restricciones implementadas y la coherencia de los procesos que lo utilizan.
