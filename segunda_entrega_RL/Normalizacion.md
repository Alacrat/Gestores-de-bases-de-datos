# Proceso de normalización — Clínica Veterinaria

**Entrada:** modelo E-R original (`primera_entrega_ER\Diagrama_ER.md`): 20 entidades, 32 relaciones.
**Salida:** modelo relacional en **5FN** (`VET_Schema.dbml`): **47 tablas, 64 llaves foráneas**.
**Documentación tabla por tabla:** `VET_Tablas.xlsx`.
**Motor objetivo:** PostgreSQL.

---

Llevar el modelo a un esquema que elimine redundancias y anomalías de inserción, actualización y borrado, hasta el punto en que normalizar más deja de ser posible sin cambiar las reglas del negocio como fue indicado en clase.

| Forma normal | Condición                                                                                                                                            |
| :----------- | :--------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1FN**      | Atributos atómicos; sin grupos repetidos ni listas en una celda.                                                                                     |
| **2FN**      | 1FN + ningún atributo no-llave depende de _parte_ de una llave candidata compuesta.                                                                  |
| **3FN**      | 2FN + ningún atributo no-llave depende de otro atributo no-llave.                                                                                    |
| **BCNF**     | Para toda dependencia funcional X → Y no trivial, X es superllave.                                                                                   |
| **4FN**      | BCNF + toda dependencia multivaluada X →→ Y no trivial tiene a X como superllave (no se mezclan hechos multivaluados independientes).                |
| **5FN**      | 4FN + toda dependencia de reunión está implicada por las llaves candidatas (ninguna tabla se puede descomponer sin pérdida en proyecciones menores). |

Notación: `A → B` = «A determina funcionalmente a B»; `A →→ B` = «A determina multivaluadamente a B».

### Clasificación de hallazgos

| Tipo  | Significado                                                                                                                                |
| :---- | :----------------------------------------------------------------------------------------------------------------------------------------- |
| **A** | Violación real de una forma normal (dependencia problemática demostrable).                                                                 |
| **B** | Mejora preventiva: no hay violación estricta, pero es texto libre repetido que genera anomalías de consistencia; se convierte en catálogo. |
| **C** | Dato derivado: calculable desde otros datos; almacenarlo duplica información.                                                              |
| **D** | Generalización/especialización: la misma información aparece en varias tablas o hay atributos que solo aplican a ciertos casos.            |

---

## 2. Primera Forma Normal (1FN)

| Origen                                                  | Problema                                                                                                                | Tipo | Corrección                                                                                                                                                                |
| :------------------------------------------------------ | :---------------------------------------------------------------------------------------------------------------------- | :--- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `Veterinario.especialidad`                              | Un profesional puede tener varias especialidades.                                                                       | A    | Catálogo `especialidad` + tabla puente `veterinario_especialidad`.                                                                                                        |
| `Medicamento.principio_activo`                          | Los fármacos combinados tienen varios principios activos.                                                               | A    | Catálogo `principio_activo` + tabla puente `medicamento_principio_activo`.                                                                                                |
| `VacunacionRecordatorio.lote_producto`                  | Texto libre que representa un lote ya existente en inventario.                                                          | A    | FK `vacunacion.id_lote → lote_medicamento`.                                                                                                                               |
| `Propietario`, `Sede`, `Proveedor`: `telefono`, `email` | Una persona, sede o proveedor puede tener varios teléfonos y correos; un solo campo obliga a listas dentro de la celda. | A    | `persona_telefono`, `persona_email`, `sede_telefono`, `sede_email`, `proveedor_telefono`, `proveedor_email` (llave compuesta `(dueño, valor)` + `tipo` y `es_principal`). |
| `TratamientoMedicamento.dosis`                          | Valor compuesto («5 mg») que mezcla cantidad y unidad.                                                                  | A    | `dosis_cantidad` (numérico) + `id_unidad_dosis → unidad_medida`.                                                                                                          |
| `TratamientoMedicamento.frecuencia`                     | Texto libre («cada 8 horas», «2 veces al día») no comparable ni calculable.                                             | A    | `frecuencia_horas` (entero).                                                                                                                                              |
| `tipo_documento` en `Propietario` y `Veterinario`       | Texto repetido.                                                                                                         | B    | Catálogo `tipo_documento_identidad`.                                                                                                                                      |

**Decisión sobre direcciones:** `direccion` se mantiene como una sola línea. Las direcciones colombianas («Cra 27 # 45-12 Apto 301») no tienen una estructura estable y descomponerlas en calle/número/complemento no elimina ninguna dependencia funcional; solo agregaría columnas casi siempre concatenadas de nuevo. La ciudad de la sede sí se normaliza (sección 4.4).

---

## 3. Segunda Forma Normal (2FN)

- Las tablas operativas usan **llave primaria sustituta de una columna**, por lo que no pueden tener dependencias parciales.
- Las tablas con llave compuesta (`veterinario_especialidad`, `medicamento_principio_activo`, y las de contacto) no tienen atributos que dependan solo de parte de la llave: en las de contacto, `tipo` y `es_principal` dependen del par completo `(dueño, valor)`.

El análisis sobre **llaves naturales** reveló un caso real:

### 3.1 `Medicamento` (Tipo A)

Original: `Medicamento(id_medicamento, id_sede, nombre, principio_activo, presentacion, laboratorio, stock_actual, stock_minimo, precio_unitario, activo)`. Llave natural: `(nombre, presentacion, laboratorio, id_sede)`.

```
(nombre, presentacion, laboratorio)          → principio_activo               -- depende solo del PRODUCTO
(nombre, presentacion, laboratorio, id_sede) → stock_minimo, precio_unitario  -- depende de PRODUCTO × SEDE
```

`principio_activo` depende de parte de la llave natural (2FN) y, con llave sustituta, es transitiva (3FN). Con 3 sedes, los datos del fármaco se repiten 3 veces.

| Tabla resultante               | Contiene                                    | Depende de         |
| :----------------------------- | :------------------------------------------ | :----------------- |
| `medicamento`                  | nombre, laboratorio, presentación           | el producto        |
| `medicamento_principio_activo` | principios activos (N:M)                    | el producto        |
| `medicamento_sede`             | `stock_minimo`, `precio_unitario`, `activo` | producto × sede    |
| `lote_medicamento`             | lotes, vencimientos, cantidades             | `medicamento_sede` |

---

## 4. Tercera Forma Normal (3FN) y BCNF

### 4.1 `Mascota`: raza → especie (Tipo A)

```
id_mascota → raza
raza       → especie
```

`especie(id_especie, nombre)` y `raza(id_raza, id_especie, nombre)`; `mascota` solo guarda `id_raza`. Cada especie incluye una raza «Sin raza definida» para que `id_raza` sea `NOT NULL` y no haya que duplicar `id_especie`.

### 4.2 `HistoriaClinica`: id_cita → id_mascota (Tipo A, controlada)

```
id_historia → id_cita → id_mascota
```

`id_cita` es opcional, así que `id_mascota` no se puede eliminar. La consistencia se garantiza con **FK compuesta**:

```
historia_clinica (id_cita, id_mascota) → cita (id_cita, id_mascota)
hospitalizacion  (id_historia, id_mascota) → historia_clinica (id_historia, id_mascota)
```

### 4.3 `Hospitalizacion` (Tipos A y C)

- `numero_jaula` + `id_sede` → tabla `jaula(id_jaula, id_sede, numero_jaula)` con `UNIQUE(id_sede, numero_jaula)`. La sede se obtiene por `jaula` (se elimina `id_jaula → id_sede` transitivo).
- **`estado` es derivable (Tipo C):** «internado» ⇔ `fecha_salida_real IS NULL`. Lo único que aporta información propia es _cómo terminó_ la estancia. Se reemplaza por `tipo_salida` (alta / traslado / fallecimiento, `NULL` mientras siga internado) con `CHECK ((fecha_salida_real IS NULL) = (tipo_salida IS NULL))`. El estado se obtiene en la vista `v_hospitalizacion_estado`.

### 4.4 `VacunacionRecordatorio` se divide en dos hechos (Tipos A, C y D)

El original mezclaba en una tabla un **hecho ocurrido** (aplicación de la vacuna) y un **evento futuro** (recordatorio):

```
estado = 'pendiente'  →  fecha_aplicacion, id_veterinario y lote son NULL
estado = 'aplicado'   →  esas columnas son obligatorias
```

Es una dependencia condicionada por `estado` (columnas nulas según el valor de otra columna), síntoma de dos entidades fusionadas. Además `estado` es derivable.

| Tabla                     | Contenido                                                                                                         |
| :------------------------ | :---------------------------------------------------------------------------------------------------------------- |
| `vacunacion`              | `id_mascota`, `id_servicio`, `id_veterinario`, `id_lote`, `fecha_aplicacion` — todo `NOT NULL` salvo el lote.     |
| `recordatorio_vacunacion` | `id_mascota`, `id_servicio`, `fecha_proxima`, `notificacion_enviada`, `id_vacunacion_cumplida` (opcional, único). |

FK compuesta `(id_vacunacion_cumplida, id_mascota, id_servicio) → vacunacion`: un recordatorio solo puede cumplirse con una vacuna de la misma mascota y del mismo servicio. El estado Pendiente / Aplicado / Vencido se calcula en `v_estado_recordatorio`.

### 4.5 `Propietario` y `Veterinario`: supertipo `persona` (Tipo D)

```
(id_tipo_documento, numero_documento) → nombre, apellido
```

Esta dependencia aparecía en **dos tablas**. Si un veterinario es también propietario de una mascota (caso frecuente), sus datos personales se duplicaban y podían divergir.

**Solución:** `persona(id_persona, id_tipo_documento, numero_documento, nombre, apellido, direccion)` como supertipo; `propietario` y `veterinario` son subtipos con `id_persona` `UNIQUE NOT NULL`, y conservan solo sus atributos propios (`fecha_registro`; `id_sede`, `id_rol`, `numero_licencia`, `fecha_ingreso`, `activo`). Los contactos (`persona_telefono`, `persona_email`) cuelgan de `persona`, no de cada rol. Se mantuvieron `id_propietario` e `id_veterinario` como llaves de los subtipos para no alterar las FK del resto del modelo.

### 4.6 `DetalleFactura`: arco exclusivo → supertipo/subtipos (Tipos A y D)

El original tenía `id_servicio` e `id_medicamento` nulos de forma excluyente: cada columna depende del valor de la otra (nulidad condicionada).

```
detalle_factura              (id_detalle, id_factura, tipo_item, cantidad, precio_unitario)   -- atributos comunes
detalle_factura_servicio     (id_detalle, tipo_item = 'servicio',    id_servicio)             -- solo servicios
detalle_factura_medicamento  (id_detalle, tipo_item = 'medicamento', id_medicamento)          -- solo medicamentos
```

`tipo_item` es el discriminador. La FK compuesta `(id_detalle, tipo_item) → detalle_factura(id_detalle, tipo_item)` más el `CHECK tipo_item = '...'` en cada subtipo impide que una línea aparezca en ambos subtipos. Cada subtipo tiene solo columnas `NOT NULL`.

### 4.7 Catálogos preventivos (Tipo B)

| Atributo original                         | Catálogo                  | Motivo                                                                                                                                                                              |
| :---------------------------------------- | :------------------------ | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Sede.ciudad`                             | `ciudad` → `departamento` | Evita variantes de escritura; deja un lugar para el departamento.                                                                                                                   |
| `Servicio.categoria`                      | `categoria_servicio`      | Categorías extensibles sin cambiar el esquema.                                                                                                                                      |
| `Mascota.especie`                         | `especie`                 | Ver 4.1.                                                                                                                                                                            |
| `Medicamento.laboratorio`                 | `laboratorio`             | Evita transitividad si gana atributos (NIT, contacto).                                                                                                                              |
| `Medicamento.presentacion`                | `presentacion`            | Normaliza «tableta / Tableta / tab.».                                                                                                                                               |
| `Veterinario.rol` y `Usuario.rol_sistema` | `rol` (único)             | **El mismo dominio estaba definido dos veces** como enumeraciones separadas. Un catálogo evita la duplicación; el significado sigue siendo distinto (función laboral vs. permisos). |
| `Pago.medio_pago`                         | `medio_pago`              | Los medios de pago cambian con frecuencia (nuevas billeteras, plataformas); no debe requerir `ALTER TYPE`.                                                                          |
| unidad de la dosis                        | `unidad_medida`           | Ver sección 2.                                                                                                                                                                      |

Se mantuvieron como **ENUM** los dominios cerrados y estables: `sexo`, `estado` (mascota, cita, factura), `canal`, `severidad`, `tipo_antecedente`, `tipo_archivo`, `tipo_telefono`, `tipo_salida`, `tipo_item`.

### 4.8 Casos revisados que **no** son violación

| Caso                                               | Análisis                                                                                                           |
| :------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------- |
| `Cita.id_sede` vs `Veterinario.id_sede`            | No hay dependencia funcional: un profesional puede atender en otra sede.                                           |
| `TratamientoMedicamento.id_lote`                   | La cadena `lote → medicamento_sede → medicamento` cruza tablas distintas; no es transitividad dentro de una tabla. |
| `Historia.id_veterinario` vs `Cita.id_veterinario` | Puede atender un reemplazo; no hay dependencia funcional.                                                          |

### 4.9 Verificación de BCNF

Todo determinante es llave candidata o superllave:

| Tabla                        | Llaves candidatas                                                                                              |
| :--------------------------- | :------------------------------------------------------------------------------------------------------------- |
| `persona`                    | `id_persona`; `(id_tipo_documento, numero_documento)`                                                          |
| `propietario`                | `id_propietario`; `id_persona`                                                                                 |
| `veterinario`                | `id_veterinario`; `id_persona`; `numero_licencia`                                                              |
| `mascota`                    | `id_mascota`; `numero_microchip`                                                                               |
| `usuario`                    | `id_usuario`; `nombre_usuario`; `id_veterinario`                                                               |
| `sede`                       | `id_sede`; `nombre`                                                                                            |
| `ciudad`                     | `id_ciudad`; `(id_departamento, nombre)`                                                                       |
| `raza`                       | `id_raza`; `(id_especie, nombre)`                                                                              |
| `servicio`                   | `id_servicio`; `nombre`                                                                                        |
| `proveedor`                  | `id_proveedor`; `nit`                                                                                          |
| `medicamento`                | `id_medicamento`; `(nombre, id_laboratorio, id_presentacion)`                                                  |
| `medicamento_sede`           | `id_medicamento_sede`; `(id_medicamento, id_sede)`                                                             |
| `lote_medicamento`           | `id_lote`; `(id_medicamento_sede, numero_lote)`                                                                |
| `jaula`                      | `id_jaula`; `(id_sede, numero_jaula)`                                                                          |
| `horario_veterinario`        | `id_horario`; `(id_veterinario, dia_semana, hora_inicio)`                                                      |
| `historia_clinica`           | `id_historia`; `id_cita`. La dependencia `id_cita → id_mascota` es válida porque `id_cita` es llave candidata. |
| `hospitalizacion`            | `id_hospitalizacion`; `id_historia`                                                                            |
| `recordatorio_vacunacion`    | `id_recordatorio`; `id_vacunacion_cumplida`                                                                    |
| `documento`                  | `id_documento`; `url_archivo`                                                                                  |
| `detalle_factura`            | `id_detalle`; `(id_detalle, tipo_item)`                                                                        |
| Tablas de contacto y puentes | La llave compuesta completa; sin atributos que dependan de otra cosa.                                          |
| Resto                        | Solo la llave primaria                                                                                         |

---

## 5. Datos derivados (Tipo C)

| Atributo original                | Cómo se calcula                                   | Decisión                                                                      |
| :------------------------------- | :------------------------------------------------ | :---------------------------------------------------------------------------- |
| `Mascota.peso_actual`            | Último `peso_registrado` en historias             | **Eliminado** → `v_peso_actual_mascota`                                       |
| `Medicamento.stock_actual`       | `SUM(lote.cantidad_disponible)` de lotes vigentes | **Eliminado** → `v_stock_medicamento`                                         |
| `DetalleFactura.subtotal`        | `cantidad × precio_unitario`                      | **Eliminado** → `v_detalle_factura_item`                                      |
| `Servicio.requiere_periodicidad` | `periodicidad_dias IS NOT NULL`                   | **Reemplazado** por `periodicidad_dias` (además guarda cada cuánto se repite) |
| `Hospitalizacion.estado`         | `fecha_salida_real` + `tipo_salida`               | **Reemplazado** → `v_hospitalizacion_estado`                                  |
| `VacunacionRecordatorio.estado`  | Cumplido / fecha próxima vs. hoy                  | **Eliminado** → `v_estado_recordatorio`                                       |

---

## 6. Cuarta Forma Normal (4FN)

Una dependencia multivaluada `X →→ Y` aparece cuando dos hechos multivaluados **independientes** de la misma entidad se guardan juntos, obligando a repetir filas por cada combinación.

**Casos detectados (uno real en el original y otros potenciales al permitir varios valores):**

| Entidad original                                 | Dependencia multivaluada                                 | Consecuencia                                                                | Solución                                                                                                           |
| :----------------------------------------------- | :------------------------------------------------------- | :-------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------- |
| `Medicamento` (por sede) — **caso real**         | `producto →→ principio_activo` y `producto →→ sede`      | Un fármaco con 2 principios activos en 3 sedes necesitaría 2 × 3 = 6 filas. | `medicamento_principio_activo` y `medicamento_sede` separadas (sección 3.1).                                       |
| `Propietario` con `telefono` y `email` múltiples | `propietario →→ telefono` y `propietario →→ email`       | Si se guardan juntos, 3 teléfonos × 2 correos = 6 filas.                    | Una tabla de teléfonos y otra de correos por titular (sección 2).                                                  |
| `Veterinario` con `especialidad` y `horario`     | `veterinario →→ especialidad` y `veterinario →→ horario` | Potencial: combinaciones artificiales especialidad × bloque de horario.     | El horario ya era una tabla aparte en el original; se conserva y la especialidad va en `veterinario_especialidad`. |

**Verificación:** cada tabla de contacto y cada tabla puente contiene una sola relación multivaluada (o solo columnas de llave), por lo que la única dependencia multivaluada posible es trivial. En el resto de tablas no existen dos hechos multivaluados independientes. **El modelo cumple 4FN.**

---

## 7. Quinta Forma Normal (5FN)

Una dependencia de reunión problemática aparece cuando una tabla ternaria puede reconstruirse sin pérdida como la reunión de tres tablas binarias.

**Revisión de tablas con tres o más llaves foráneas:**

| Tabla                                                       | ¿Descomponible?                                                                                                                                                                                                |
| :---------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `cita` (mascota, veterinario, servicio, sede)               | No. Es una entidad con identidad y atributos propios (`fecha_hora`, `estado`...). Que exista la pareja mascota–veterinario, veterinario–servicio y mascota–servicio no implica que exista _esa_ cita concreta. |
| `historia_clinica`, `vacunacion`, `recordatorio_vacunacion` | No, mismo razonamiento: cada fila es un hecho con atributos propios.                                                                                                                                           |
| `lote_medicamento` (medicamento_sede, proveedor)            | No. Solo dos llaves foráneas y atributos propios (`numero_lote`, vencimiento, cantidad).                                                                                                                       |
| `tratamiento_medicamento` (historia, lote, unidad)          | No. Tiene `cantidad_utilizada`, `dosis_cantidad`, `frecuencia_horas` que dependen de la tríada completa.                                                                                                       |

**Tablas puente (`veterinario_especialidad`, `medicamento_principio_activo`)** son binarias, no ternarias: cumplen 5FN. **No existen tablas ternarias de «solo llaves»**, que son la fuente típica de violaciones de 5FN. **El modelo cumple 5FN.**

---
