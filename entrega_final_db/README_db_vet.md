# Base de datos veterinaria: revisión, correcciones y guía de conceptos

Este documento explica qué se revisó, qué se encontró, qué se corrigió y qué significa cada concepto usado en el SQL.

**Archivos entregados**

| Archivo | Descripción |
|---|---|
| `db_vet_corregido.sql` | Script limpio y corregido (PostgreSQL 13+) |
| `README_db_vet.md` | Este documento |

**Cómo se verificó:** el SQL original y el corregido se ejecutaron en un PostgreSQL 16 real. Se comparó columna por columna (228 columnas, idénticas) y se hizo una prueba con datos, incluyendo casos que deben fallar.

---

## 1. ¿El SQL corresponde al PDF?

**Sí, en estructura. Pero el SQL tiene errores de dirección en 3 relaciones** que el PDF no puede mostrar con claridad (sección 2).

| Elemento | PDF | SQL original | Resultado |
|---|---|---|---|
| Tablas | 47 | 47 | ✅ Coinciden |
| Columnas, tipos y nulabilidad | — | 228 | ✅ Coinciden |
| Tipos enumerados | 11 | 11 | ✅ Mismos valores (`sexo_mascota` = `M`, `H`) |
| Relaciones (FK) | 64 | 64 | ✅ Mismos nombres, uno a uno |
| Claves compuestas `(id_cita, id_mascota)`, `(id_historia, id_mascota)`, `(id_vacunacion, id_mascota, id_servicio)`, `(id_detalle, tipo_item)` | Sí | Sí | ✅ Coinciden |

> **Nota sobre el PDF:** un diagrama muestra que dos tablas están relacionadas y su cardinalidad (`1`, `*`), pero la **flecha** de una relación 1:1 es ambigua. Por eso el error de dirección pasó desapercibido. Para decidir cuál era la correcta se usaron las columnas: `propietario` tiene `id_persona`, `veterinario` tiene `id_persona` y `usuario` tiene `id_veterinario`. La FK siempre va en la tabla que **contiene** la columna.

---

## 2. Errores encontrados

### 🔴 Error crítico: 3 claves foráneas invertidas

```sql
-- ORIGINAL (incorrecto)
ALTER TABLE "persona"     ADD CONSTRAINT "fk_propietario_persona" FOREIGN KEY ("id_persona")     REFERENCES "propietario" ("id_persona");
ALTER TABLE "persona"     ADD CONSTRAINT "fk_veterinario_persona" FOREIGN KEY ("id_persona")     REFERENCES "veterinario" ("id_persona");
ALTER TABLE "veterinario" ADD CONSTRAINT "fk_usuario_veterinario" FOREIGN KEY ("id_veterinario") REFERENCES "usuario" ("id_veterinario");
```

Aquí `persona` dependía de `propietario` y de `veterinario`. Se pensaba al revés: la persona existe primero y luego se le asigna un rol.

**Consecuencias reales** (probadas en el motor):

1. **No se podía insertar ninguna persona.** El motor respondió: `Key (id_persona)=(1) is not present in table "propietario"`.
2. Para crear un propietario hace falta una persona, y para crear una persona hace falta un propietario. Es un **círculo sin salida**.
3. Toda persona tendría que ser a la vez propietario **y** veterinario.
4. `usuario.id_veterinario` quedaba sin FK: se podía guardar un veterinario inexistente. Además, obligaba a que todo veterinario tuviera un usuario, lo que contradice el comentario "NULL para cuentas puramente técnicas".

```sql
-- CORREGIDO: la FK va en el subtipo, apuntando al supertipo
propietario.id_persona     → persona.id_persona        (UNIQUE = relación 1:1)
veterinario.id_persona     → persona.id_persona        (UNIQUE = relación 1:1)
usuario.id_veterinario     → veterinario.id_veterinario (UNIQUE, nullable)
```

Tras la corrección, una misma persona sí puede ser propietario y veterinario a la vez (se probó).

### 🟡 Defectos menores

| # | Problema | Efecto | Solución |
|---|---|---|---|
| 1 | Los comentarios mencionan vistas que **no existían**: `v_peso_actual_mascota`, `v_estado_recordatorio`, stock actual y subtotal de línea | Datos derivados anunciados pero imposibles de consultar | Se crearon las 4 vistas |
| 2 | Faltan índices en muchas FK (`cita.id_servicio`, `servicio.id_categoria`, `vacunacion.id_lote`, `pago.id_medio_pago`, etc.) | PostgreSQL **no** indexa las FK automáticamente: joins y borrados lentos | Se agregaron 28 índices |
| 3 | Comentarios con historia de diseño ("antes texto", "reemplaza al booleano", "se elimina") | Ruido: describen el pasado, no el estado actual | Reescritos para describir lo que existe hoy |
| 4 | Índices sin nombre (`CREATE INDEX ON ...`) | Nombres autogenerados, difíciles de mantener | Todos tienen nombre (`idx_...`, `uq_...`) |
| 5 | `DEFERRABLE INITIALLY IMMEDIATE` en las 64 FK | Ruido sin efecto práctico (ver sección 3) | Eliminado |
| 6 | Reglas de negocio sin proteger (dos teléfonos principales, dos hospitalizaciones abiertas en una jaula...) | Datos inconsistentes posibles | Índices únicos parciales (sección 6) |

---

## 3. ¿Por qué el SQL original tenía tantos `ALTER`?

Tienes razón en que eran innecesarios. **El archivo fue exportado automáticamente desde dbdiagram.io**, y esa herramienta genera siempre el mismo patrón:

1. Primero crea **todas** las tablas sin relaciones.
2. Al final agrega **todas** las FK con `ALTER TABLE ... ADD CONSTRAINT`.

Lo hace así porque la herramienta no se esfuerza por ordenar las tablas: si `ciudad` referencia a `departamento` y aún no existe, el `CREATE` fallaría. Separar las FK evita el problema, pero a costa de un script largo y difícil de leer, con la definición de cada tabla repartida en dos lugares.

**Qué se hizo:** las FK ahora están **dentro de cada `CREATE TABLE`**, y las tablas están ordenadas para que cada una referencie solo tablas ya creadas. Con las 3 FK invertidas arregladas **no hay ciclos**, así que este orden es posible.

```sql
-- Antes: 2 sentencias separadas por 400 líneas
CREATE TABLE "ciudad" ( "id_ciudad" ..., "id_departamento" integer NOT NULL, ... );
...
ALTER TABLE "ciudad" ADD CONSTRAINT "fk_ciudad_departamento" FOREIGN KEY ("id_departamento")
  REFERENCES "departamento" ("id_departamento") ON DELETE RESTRICT DEFERRABLE INITIALLY IMMEDIATE;

-- Ahora: todo junto
CREATE TABLE ciudad (
  id_ciudad       INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  id_departamento INTEGER NOT NULL REFERENCES departamento (id_departamento),
  nombre          VARCHAR(80) NOT NULL,
  UNIQUE (id_departamento, nombre)
);
```

**Otras limpiezas del mismo tipo:**

- Se quitaron las comillas dobles de todos los identificadores. Solo son necesarias con mayúsculas o espacios.
- Los índices únicos que respaldaban claves compuestas pasaron a `UNIQUE (...)` dentro de la tabla.
- Se quitó `ON DELETE RESTRICT`: el comportamiento por defecto (`NO ACTION`) también impide borrar un padre con hijos. Solo se conserva `ON DELETE CASCADE` donde sí se necesita.
- Se quitó `DEFERRABLE INITIALLY IMMEDIATE`, que equivale al comportamiento normal salvo que se active manualmente.

**Resultado:** el script pasó de 754 a 645 líneas, aun incluyendo los índices, las vistas y las reglas nuevas, y cada tabla se lee completa en un solo lugar.

---

## 4. Estructura del modelo

El script está dividido en secciones numeradas:

| Sección | Contenido | Tablas |
|---|---|---|
| 1 | Tipos enumerados | 11 tipos |
| 2 | Catálogos | `departamento`, `ciudad`, `tipo_documento_identidad`, `rol`, `especie`, `raza`, `especialidad`, `categoria_servicio`, `laboratorio`, `presentacion`, `principio_activo`, `unidad_medida`, `medio_pago` |
| 3 | Sedes | `sede`, `sede_telefono`, `sede_email` |
| 4 | Personas y personal | `persona`, `persona_telefono`, `persona_email`, `propietario`, `mascota`, `veterinario`, `veterinario_especialidad`, `usuario`, `horario_veterinario` |
| 5 | Atención clínica | `servicio`, `cita`, `historia_clinica`, `antecedente_medico`, `jaula`, `hospitalizacion`, `documento` |
| 6 | Inventario | `proveedor` (+ teléfono/email), `medicamento`, `medicamento_principio_activo`, `medicamento_sede`, `lote_medicamento` |
| 7 | Vacunas y tratamientos | `vacunacion`, `recordatorio_vacunacion`, `tratamiento_medicamento` |
| 8 | Facturación | `factura`, `detalle_factura`, `detalle_factura_servicio`, `detalle_factura_medicamento`, `pago` |
| 9 | Índices | FK, consultas frecuentes y reglas de negocio |
| 10 | Vistas | 4 vistas con datos derivados |
| 11 | Comentarios | Documentación dentro de la BD |

---

## 5. Conceptos usados en el SQL

### 5.1 Tipos de datos y enumerados

**`CREATE TYPE ... AS ENUM`** define un tipo con un conjunto fijo de valores permitidos.

```sql
CREATE TYPE estado_cita AS ENUM ('programada', 'confirmada', 'completada', 'cancelada', 'no_asistio');
```

Cualquier otro valor se rechaza. Se usa en lugar de un `VARCHAR` con `CHECK` porque ocupa menos espacio y el valor queda documentado en el esquema. Su desventaja: quitar un valor luego es complicado. Para listas que cambian con frecuencia (como `medio_pago`) se usa una **tabla de catálogo**.

| Tipo | Significado |
|---|---|
| `INTEGER` / `SMALLINT` | Entero de 4 bytes / 2 bytes (hasta 32 767) |
| `VARCHAR(n)` | Texto de hasta `n` caracteres |
| `TEXT` | Texto sin límite (diagnósticos, observaciones) |
| `DECIMAL(12,2)` | Número exacto: 12 dígitos, 2 decimales. **Se usa para dinero** porque no tiene errores de redondeo como `FLOAT` |
| `DECIMAL(4,1)` | Para temperatura, ej. `38.5` |
| `DATE` / `TIME` / `TIMESTAMP` | Fecha / hora / fecha con hora |
| `BOOLEAN` | Verdadero o falso |

### 5.2 Claves

**`PRIMARY KEY` (PK):** identifica de forma única cada fila. Implica `NOT NULL` y `UNIQUE`.

**`GENERATED BY DEFAULT AS IDENTITY`:** la base de datos genera el número automáticamente (1, 2, 3...). Es el estándar SQL moderno y reemplaza a `SERIAL`. Con `BY DEFAULT` aún puedes insertar un valor manual, por ejemplo al migrar datos.

**`FOREIGN KEY` / `REFERENCES` (FK):** una columna que apunta a la PK de otra tabla. Garantiza **integridad referencial**: no puedes crear una mascota con un propietario inexistente.

```sql
id_propietario INTEGER NOT NULL REFERENCES propietario (id_propietario)
```

**`ON DELETE`:** qué pasa al borrar el padre.

| Opción | Efecto | Dónde se usa |
|---|---|---|
| (por defecto) `NO ACTION` | Impide borrar si hay hijos | La gran mayoría de relaciones |
| `CASCADE` | Borra también los hijos | Teléfonos, emails, especialidades, horarios, subtipos de factura |

**Clave primaria compuesta:** `PRIMARY KEY (id_sede, telefono)`. La unicidad se evalúa sobre la **combinación**: una sede puede tener muchos teléfonos, pero no el mismo número dos veces.

**`UNIQUE`:** impide duplicados sin ser la PK. `numero_microchip VARCHAR(30) UNIQUE` permite varios `NULL` (mascotas sin microchip), pero no dos iguales.

**Cardinalidad 1:1 y 1:0..1:** una columna FK con `UNIQUE` hace que cada fila del padre tenga como máximo una del hijo.

- `propietario.id_persona` es `NOT NULL UNIQUE`: relación **1:1**.
- `historia_clinica.id_cita` es solo `UNIQUE` y admite `NULL`: relación **1:0..1** (una historia puede existir sin cita, por ejemplo una urgencia).

### 5.3 Claves foráneas compuestas (el patrón más importante del modelo)

Estas relaciones usan **más de una columna** para garantizar coherencia entre datos:

```sql
-- historia_clinica
FOREIGN KEY (id_cita, id_mascota) REFERENCES cita (id_cita, id_mascota)
```

**Problema que resuelve:** con una FK simple (`id_cita`), se podría registrar la historia clínica de *Luna* usando la cita de *Rex*. Al incluir también `id_mascota`, el motor exige que cita y historia sean de la **misma mascota**.

Para que funcione, la tabla destino necesita un `UNIQUE (id_cita, id_mascota)`. Esa es la razón de que existan esas restricciones aparentemente redundantes. Se probó: insertar una historia de la mascota 2 con una cita de la mascota 1 es rechazado.

Se aplica igual en:

| Tabla hija | Garantiza que... |
|---|---|
| `historia_clinica` → `cita` | la cita sea de la misma mascota |
| `hospitalizacion` → `historia_clinica` | la historia sea de la misma mascota |
| `recordatorio_vacunacion` → `vacunacion` | la vacunación cumplida sea de la misma mascota **y** el mismo servicio |
| subtipos de factura → `detalle_factura` | el subtipo coincida con `tipo_item` |

**Detalle:** con `id_cita = NULL`, la FK compuesta **no se evalúa** (comportamiento `MATCH SIMPLE`, el de por defecto). Por eso las relaciones opcionales funcionan.

### 5.4 Restricciones `CHECK`

Validan una condición en cada inserción o actualización.

```sql
CONSTRAINT ck_horario_rango CHECK (hora_fin > hora_inicio)
CONSTRAINT ck_factura_total CHECK (total = subtotal + impuestos)
```

**Patrón de "ambos o ninguno":** `CHECK ((a IS NULL) = (b IS NULL))` obliga a que dos columnas estén las dos vacías o las dos llenas.

| Restricción | Regla |
|---|---|
| `ck_mascota_fallecimiento` | `fecha_fallecimiento` existe **si y solo si** `estado = 'fallecido'` |
| `ck_cita_videollamada` | `url_videollamada` existe **si y solo si** el canal es `telemedicina` |
| `ck_hosp_salida` | `tipo_salida` existe **si y solo si** hay `fecha_salida_real` |
| `ck_hosp_estimada` / `ck_hosp_real` | la fecha de salida no puede ser anterior al ingreso |
| `ck_horario_dia` | `dia_semana` entre 1 y 7 |
| `ck_lote_fechas` | el vencimiento no es anterior al ingreso |
| Varios `... >= 0` / `> 0` | precios, cantidades y dosis no negativos |

### 5.5 Supertipo y subtipo (generalización)

Se usa en dos lugares. La idea: los datos comunes van en una tabla padre y los específicos en tablas hijas.

**a) `persona` → `propietario` / `veterinario`**

```
        persona (nombre, documento, dirección...)
        ▲                          ▲
 propietario (fecha_registro)   veterinario (licencia, sede, rol...)
```

Una persona que es dueña de una mascota **y** trabaja en la clínica se guarda una sola vez, sin duplicar nombre ni documento.

**b) `detalle_factura` → `detalle_factura_servicio` / `detalle_factura_medicamento`**

Cada línea de factura es un servicio **o** un medicamento. Se usa un **discriminador** (`tipo_item`) y un truco para que sea imposible mezclar:

```sql
CREATE TABLE detalle_factura_servicio (
  id_detalle INTEGER PRIMARY KEY,
  tipo_item  tipo_item_factura NOT NULL DEFAULT 'servicio' CHECK (tipo_item = 'servicio'),
  ...
  FOREIGN KEY (id_detalle, tipo_item) REFERENCES detalle_factura (id_detalle, tipo_item)
);
```

El `CHECK` fuerza que este subtipo siempre diga `'servicio'`, y la FK compuesta lo obliga a colgar de una línea que **también** diga `'servicio'`. Un servicio no puede quedar enlazado a una línea de medicamento.

### 5.6 Índices

Un índice es una estructura auxiliar que acelera las búsquedas, a cambio de ocupar espacio y ralentizar un poco las escrituras.

| Tipo | Para qué |
|---|---|
| Índice normal (`idx_...`) | Acelerar búsquedas y joins |
| Índice único (`UNIQUE`) | Acelerar **y** evitar duplicados |
| Índice compuesto | Ej. `(id_mascota, fecha_hora)`: sirve para "citas de esta mascota ordenadas por fecha" |
| **Índice único parcial** (`WHERE ...`) | Aplica la unicidad solo a las filas que cumplen la condición |

> **Importante:** PostgreSQL crea índices solos para las `PRIMARY KEY` y `UNIQUE`, pero **no para las FK**. Por eso se agregaron explícitamente. Sin ellos, borrar un padre o hacer un join por esa columna obliga a recorrer toda la tabla hija.

### 5.7 Índices únicos parciales (reglas de negocio)

Son una forma elegante de forzar reglas que dependen de un estado:

```sql
-- Solo UN teléfono principal por persona (permite muchos con es_principal = false)
CREATE UNIQUE INDEX uq_persona_tel_principal ON persona_telefono (id_persona) WHERE es_principal;

-- Una jaula no puede tener dos hospitalizaciones abiertas
CREATE UNIQUE INDEX uq_hosp_jaula_abierta ON hospitalizacion (id_jaula) WHERE fecha_salida_real IS NULL;
```

| Índice | Regla |
|---|---|
| 6 índices `uq_*_principal` | Un solo teléfono y un solo email principal por sede, persona y proveedor |
| `uq_hosp_jaula_abierta` | Una jaula, una hospitalización abierta |
| `uq_hosp_mascota_abierta` | Una mascota no puede estar hospitalizada dos veces a la vez |
| `uq_cita_vet_hora_activa` | Un veterinario no puede tener dos citas activas a la misma hora (las canceladas no cuentan) |
| `uq_recordatorio_pendiente` | Un solo recordatorio pendiente por mascota y servicio |

> ⚠️ Estas 4 reglas de negocio (jaula, mascota, cita, recordatorio) son **supuestos razonables**. Si en tu clínica varias mascotas comparten jaula, o un veterinario atiende citas simultáneas, elimina el índice correspondiente.

### 5.8 Vistas

Una vista es una consulta guardada con nombre; se usa como una tabla pero **no almacena datos**, siempre muestra el valor actual.

Se usan para **datos derivados**: aquellos que se pueden calcular a partir de otros. Guardarlos en la tabla crearía riesgo de que se desincronicen.

| Vista | Qué calcula | Por qué no es una columna |
|---|---|---|
| `v_peso_actual_mascota` | Último peso registrado de cada mascota | Cambia con cada consulta; ya está en `historia_clinica` |
| `v_estado_recordatorio` | `cumplido`, `vencido` o `pendiente` | Depende de la fecha de hoy; una columna quedaría desactualizada |
| `v_stock_medicamento_sede` | Suma de `cantidad_disponible` de los lotes, y si está bajo el mínimo | Es la suma de los lotes |
| `v_detalle_factura_subtotal` | `cantidad × precio_unitario` | Se calcula de dos columnas |

```sql
SELECT * FROM v_stock_medicamento_sede WHERE bajo_minimo;   -- ¿qué hay que reponer?
SELECT * FROM v_estado_recordatorio WHERE estado = 'vencido'; -- vacunas atrasadas
```

### 5.9 Normalización y decisiones de diseño

| Decisión | Explicación |
|---|---|
| **Tablas de teléfono y email separadas** | Una persona puede tener varios. Poner `telefono1`, `telefono2` rompería la 1FN (un valor por celda). |
| **Catálogos** (`especie`, `raza`, `rol`...) | Evitan repetir texto y errores de escritura ("Canino" vs "canino"). |
| **Tabla puente** (`veterinario_especialidad`, `medicamento_principio_activo`) | Relaciones muchos-a-muchos: un veterinario tiene varias especialidades y viceversa. |
| **La especie no está en `mascota`** | Se obtiene vía `raza → especie`. Duplicarla permitiría inconsistencias (un "Labrador" que sea "Felino"). |
| **La sede no está en `hospitalizacion`** | Se obtiene vía `jaula → sede`. |
| **Baja lógica** (`activo = false`) | En vez de borrar un veterinario o proveedor, se desactiva para conservar el historial. |
| **`persona` sin rol** | El rol (`propietario`/`veterinario`) se define por la existencia en la tabla hija. |
| **`vacunacion` y `recordatorio_vacunacion` separadas** | Una es un hecho ocurrido; la otra, un evento futuro. Unirlas dejaría columnas vacías según el estado. |
| **Medicamento global + `medicamento_sede`** | El catálogo es único; el precio y el stock mínimo varían por sede. |
| **Lote** | Cada ingreso de medicamento se controla por lote y fecha de vencimiento (trazabilidad). |
| **Desnormalización controlada en `factura`** | `subtotal`, `impuestos` y `total` se guardan aunque son calculables, porque una factura emitida es un comprobante que **no debe cambiar** aunque luego cambien los precios. Por eso `precio_unitario` también se congela en cada línea. |

### 5.10 `COMMENT ON`

Guarda documentación **dentro** de la base de datos, visible desde herramientas como DBeaver, pgAdmin o con `\d+` en `psql`.

```sql
COMMENT ON COLUMN horario_veterinario.dia_semana IS '1 = Lunes ... 7 = Domingo';
```

---

## 6. Qué cambió exactamente (resumen)

| Tipo de cambio | Detalle |
|---|---|
| 🔴 **Corregido** | 3 FK invertidas (`propietario`, `veterinario`, `usuario`) |
| 🧹 **Limpieza** | FK dentro de `CREATE TABLE`, sin `ALTER`, sin `DEFERRABLE`, sin `ON DELETE RESTRICT` redundante, sin comillas, tablas ordenadas por dependencia |
| ➕ **Agregado** | 28 índices en FK, 6 índices únicos de "principal", 4 índices de reglas de negocio, 4 vistas |
| ✏️ **Reescrito** | Comentarios descriptivos sin historia de diseño |
| ✅ **Intacto** | Tablas, columnas, tipos, nulabilidad, `CHECK`, valores por defecto y enums |

---

## 7. Pendientes recomendados (no implementados)

Estas reglas **no se pueden expresar con restricciones simples**; requieren *triggers* o lógica en la aplicación. Se dejan documentadas para que decidas.

| # | Regla | Riesgo si no se controla |
|---|---|---|
| 1 | `cita.id_sede` debería coincidir con la sede del veterinario (o la sede de la mascota) | Citas en sedes incoherentes |
| 2 | Descontar `lote_medicamento.cantidad_disponible` al registrar un `tratamiento_medicamento` o una `vacunacion` | Stock que no refleja lo usado |
| 3 | El lote usado en un tratamiento debería ser de la **misma sede** que atendió | Medicamentos de otra sede |
| 4 | `vacunacion.id_servicio` debería ser de la categoría "Vacuna" | Vacunas registradas con servicios que no lo son |
| 5 | `factura.subtotal` debería igualar la suma de `v_detalle_factura_subtotal` | Totales que no cuadran con las líneas |
| 6 | La suma de `pago.monto` no debería superar `factura.total`, y `estado_pago` debería actualizarse sola | Facturas "pagadas" sin pagos suficientes |
| 7 | Cada `detalle_factura` debería tener **exactamente** un subtipo | Hoy el subtipo no puede ser incorrecto, pero **sí puede faltar**. Requiere un *constraint trigger* diferido |
| 8 | Que los horarios de un veterinario no se solapen (`EXCLUDE USING gist`, extensión `btree_gist`) | Horarios duplicados el mismo día |
| 9 | Usar `TIMESTAMPTZ` en vez de `TIMESTAMP` | Si la clínica opera en varias zonas horarias, las horas se interpretan mal. Se dejó `TIMESTAMP` para respetar el PDF |
| 10 | `veterinario` también contiene auxiliares y recepcionistas (por el campo `id_rol`) | Es un tema de **nombre**: quizá `empleado` describiría mejor la tabla |
| 11 | `veterinario.id_rol` y `usuario.id_rol` pueden contradecirse | Un rol laboral y un rol de permisos conviven; conviene definir cuál manda |

---

## 8. Cómo usar el script

```bash
# Crear la base de datos y cargar el esquema
createdb vet
psql -d vet -f db_vet_corregido.sql
```

El script **no es idempotente**: no incluye `DROP`, así que ejecutarlo dos veces sobre la misma base falla. Para recrearla desde cero:

```bash
dropdb vet && createdb vet && psql -d vet -f db_vet_corregido.sql
```

**Orden sugerido para insertar datos**, respetando las dependencias: catálogos → `sede` → `persona` → `propietario` / `veterinario` → `usuario` → `mascota` → `servicio` → `cita` → `historia_clinica` → proveedores y medicamentos → `lote_medicamento` → `vacunacion` / `tratamiento_medicamento` → `factura` y detalles → `pago`.
