# Base de datos para una clínica veterinaria

## 1. Descripción del proyecto

Este proyecto define una base de datos relacional para una clínica veterinaria con varias sedes. Organiza la información de propietarios, mascotas, personal, citas, atenciones clínicas, hospitalizaciones, medicamentos, vacunas, facturas y pagos.

La mascota es el centro del seguimiento clínico. Cada atención puede relacionarse con una cita, un profesional, tratamientos y documentos. El inventario identifica los medicamentos por sede y lote, mientras que la facturación registra los servicios y productos cobrados al propietario.

El proyecto entrega la **estructura de datos y sus vistas de consulta**. La interfaz, la autenticación, el envío de notificaciones y la ejecución de los procesos operativos corresponden a la aplicación que utilice esta base de datos.

| Característica | Descripción |
|---|---|
| Motor | MySQL 8.0.16 o superior; compatible con MySQL 8.4 |
| Almacenamiento | InnoDB, con soporte de transacciones y claves foráneas |
| Codificación | `utf8mb4`, intercalación `utf8mb4_0900_ai_ci` |
| Estructura | 47 tablas, 228 columnas y 64 claves foráneas |
| Consultas reutilizables | 5 vistas |
| Zona horaria de la sesión de instalación | UTC−05:00, correspondiente a Colombia |
| Datos iniciales | El script crea el esquema vacío, sin registros de ejemplo |

## 2. Objetivos

- Mantener un registro único de las personas y sus mascotas.
- Conservar el historial de cada atención y de los profesionales que intervienen.
- Identificar los medicamentos disponibles y los lotes utilizados.
- Registrar aplicaciones de vacunas y sus próximos recordatorios.
- Organizar los cobros y los abonos asociados a cada factura.
- Proteger la coherencia de las relaciones mediante claves y restricciones.

## 3. Archivos del proyecto

| Archivo | Contenido |
|---|---|
| `vet_db.sql` | Definición de tablas, relaciones, índices, restricciones y vistas |
| `README_db_vet.md` | Descripción funcional y guía de uso |
| `Normalizacion.md` | Explicación de la organización de los datos y de las formas normales |
| `Presentacion_Clinica_Veterinaria.pptx` | Presentación del proyecto para exposición |

## 4. Organización del modelo

Las tablas se agrupan por su función. La siguiente distribución incluye las 47 tablas del esquema.

| Módulo | Tablas | Función |
|---|---|---|
| Catálogos y ubicación (13) | `departamento`, `ciudad`, `tipo_documento_identidad`, `rol`, `especie`, `raza`, `especialidad`, `categoria_servicio`, `laboratorio`, `presentacion`, `principio_activo`, `unidad_medida`, `medio_pago` | Definir valores compartidos y clasificaciones |
| Sedes (3) | `sede`, `sede_telefono`, `sede_email` | Registrar los lugares de atención y sus contactos |
| Personas, mascotas y personal (9) | `persona`, `persona_telefono`, `persona_email`, `propietario`, `mascota`, `veterinario`, `veterinario_especialidad`, `usuario`, `horario_veterinario` | Identificar clientes, pacientes y personal |
| Atención clínica (7) | `servicio`, `cita`, `historia_clinica`, `antecedente_medico`, `jaula`, `hospitalizacion`, `documento` | Documentar la agenda y las atenciones |
| Inventario (7) | `proveedor`, `proveedor_telefono`, `proveedor_email`, `medicamento`, `medicamento_principio_activo`, `medicamento_sede`, `lote_medicamento` | Controlar productos, proveedores y existencias |
| Vacunas y tratamientos (3) | `vacunacion`, `recordatorio_vacunacion`, `tratamiento_medicamento` | Registrar aplicaciones, consumos e indicaciones |
| Facturación (5) | `factura`, `detalle_factura`, `detalle_factura_servicio`, `detalle_factura_medicamento`, `pago` | Registrar conceptos cobrados y pagos |

### 4.1 Personas, propietarios y personal

`persona` almacena el documento, nombre, apellido y dirección. Una persona puede tener un registro en `propietario`, otro en `veterinario`, ambos o ninguno. Los teléfonos y correos pertenecen a la persona y no se duplican por cada función.

La tabla `veterinario` identifica al personal según su `id_rol`. El catálogo permite funciones como veterinario, auxiliar o recepción. Por eso, la aplicación debe autorizar qué personas pueden prestar una atención clínica. `numero_licencia` es opcional para contemplar funciones que no requieren ese registro.

`usuario` representa una cuenta del sistema. Puede vincularse a un integrante del personal o tener `id_veterinario = NULL` si es una cuenta técnica. Guarda un **hash** de la contraseña; la aplicación debe generarlo y verificarlo con un mecanismo adecuado. El rol laboral y el rol de permisos tienen propósitos distintos y pueden ser diferentes.

### 4.2 Mascotas

Cada mascota tiene un propietario actual, una sede principal y una raza. La especie se obtiene a través de la raza. Para un animal sin raza definida, los datos iniciales pueden incluir una raza llamada «Sin raza definida» dentro de su especie.

Se registran nombre, nacimiento, sexo (`M` o `H`), esterilización, microchip y estado. El microchip es opcional y único cuando existe. La edad se obtiene a partir de la fecha de nacimiento, y el peso más reciente se consulta desde el historial.

### 4.3 Citas e historia clínica

Una cita identifica la mascota, el profesional programado, el servicio, la sede y la fecha. Puede ser presencial o por telemedicina. En telemedicina se exige un valor no nulo para `url_videollamada`; la aplicación valida que sea una URL utilizable.

Cada fila de `historia_clinica` representa **una atención**, no el expediente completo. El expediente de una mascota es el conjunto de sus atenciones, antecedentes y documentos. La cita es opcional para permitir atenciones sin agenda, como una urgencia.

Una cita puede asociarse como máximo a una atención. La clave foránea compuesta garantiza que ambas correspondan a la misma mascota. El profesional que atiende puede ser diferente al programado.

### 4.4 Hospitalización

Una hospitalización relaciona una mascota con una jaula, un motivo y sus fechas de ingreso y salida. Puede asociarse con una atención clínica de esa misma mascota. La sede se obtiene mediante `jaula`.

Mientras `fecha_salida_real` sea nula, la estancia aparece como `internado`. Al registrar la salida también se indica `alta`, `traslado` o `fallecimiento`. El control de disponibilidad y de cruces de estancias corresponde al proceso de hospitalización de la aplicación.

### 4.5 Medicamentos y lotes

El catálogo `medicamento` contiene la identidad del producto, su laboratorio y presentación. `medicamento_principio_activo` relaciona cada producto con uno o varios principios activos.

`medicamento_sede` define el precio y el stock mínimo de un producto en una sede. Cada `lote_medicamento` identifica proveedor, número de lote, vencimiento y cantidad disponible. Las cantidades de inventario son unidades enteras de una presentación; la dosis usa su propia cantidad numérica y unidad de medida.

`tratamiento_medicamento` registra la atención, el lote utilizado, la cantidad consumida, la dosis y, cuando corresponda, frecuencia y duración. Insertar un tratamiento o una vacunación **no descuenta automáticamente el inventario**. La aplicación realiza el registro y la actualización del lote en una misma transacción, con control de concurrencia.

### 4.6 Vacunación y recordatorios

`vacunacion` es una aplicación realizada: mascota, servicio, profesional, lote y fecha son obligatorios. `recordatorio_vacunacion` es una programación futura para una mascota y un servicio.

Al cumplir un recordatorio se registra `id_vacunacion_cumplida`. La clave compuesta exige que esa vacunación corresponda a la misma mascota y servicio. La vista calcula su estado: `cumplido`, `vencido` o `pendiente`. Un recordatorio con fecha de hoy sigue pendiente mientras no se cumpla.

`periodicidad_dias` sirve de referencia para calcular una siguiente fecha. La aplicación decide cuándo crear los recordatorios y cómo enviar las notificaciones.

### 4.7 Facturas y pagos

Una factura pertenece a un propietario y una sede. Sus líneas guardan cantidad y precio unitario histórico. Cada línea tiene un tipo, `servicio` o `medicamento`, y su tabla específica identifica el concepto cobrado.

Las restricciones impiden enlazar un subtipo incorrecto o tener ambos tipos para la misma línea. La aplicación debe crear el detalle y su subtipo en una sola transacción, porque la base permite temporalmente una línea sin subtipo.

El subtotal de cada línea es `cantidad × precio_unitario`. La factura almacena `subtotal`, `impuestos` y `total`, con la regla `total = subtotal + impuestos`. La aplicación verifica que el subtotal coincida con sus líneas y protege los importes después de la emisión.

Una factura puede recibir varios pagos. Cada pago registra fecha, medio, monto y referencia opcional. La aplicación calcula el saldo, controla los abonos y actualiza `estado_pago`. El esquema no realiza esas acciones automáticamente.

## 5. Relaciones y cardinalidades principales

Las cantidades de la tabla indican lo permitido por las claves del esquema. `0..N` significa cero o muchos registros.

| Entidad principal | Registros asociados | Regla |
|---|---|---|
| `persona` | 0..1 propietario y 0..1 integrante del personal | Cada subtipo pertenece a exactamente una persona |
| `propietario` | 0..N mascotas | Cada mascota tiene exactamente un propietario actual |
| `especie` | 0..N razas | Cada raza pertenece a una especie |
| `mascota` | 0..N citas y 0..N atenciones | Cada cita o atención pertenece a una mascota |
| `cita` | 0..1 atención | Una atención tiene 0..1 cita |
| `historia_clinica` | 0..1 hospitalización asociada | Una hospitalización tiene 0..1 atención de origen |
| `veterinario` y `especialidad` | N:M | Tabla puente `veterinario_especialidad` |
| `medicamento` y `principio_activo` | N:M | Tabla puente `medicamento_principio_activo` |
| `medicamento` y `sede` | N:M | `medicamento_sede` añade atributos de esa combinación |
| `medicamento_sede` | 0..N lotes | Cada lote pertenece a un producto en una sede |
| `factura` | 0..N líneas y 0..N pagos | El proceso de emisión exige las líneas necesarias |

## 6. Integridad y conceptos SQL

| Recurso | Uso en el proyecto |
|---|---|
| `PRIMARY KEY` | Identifica de manera única una fila |
| `AUTO_INCREMENT` | Asigna identificadores enteros automáticamente |
| `FOREIGN KEY` | Exige que los registros relacionados existan |
| `UNIQUE` | Evita documentos repetidos, microchips duplicados y combinaciones duplicadas |
| `NOT NULL` | Exige datos obligatorios |
| `CHECK` | Valida condiciones como cantidades positivas y fechas coherentes |
| `ENUM` | Restringe dominios cerrados, como el estado de una cita |
| `DECIMAL` | Representa cantidades exactas, apropiadas para importes monetarios |
| `BOOLEAN` | En MySQL es un alias numérico; los `CHECK` del script restringen sus valores a 0 y 1 |
| Índice compuesto | Apoya búsquedas como las citas de una mascota por fecha |
| Vista | Consulta guardada que obtiene información de las tablas |

Las claves compuestas protegen la coincidencia mascota–cita, mascota–historia, mascota–servicio–vacunación y detalle–tipo. Si una relación opcional contiene un identificador nulo, MySQL permite esa ausencia; la clave simple de `id_mascota` sigue verificando al paciente.

El esquema usa `ON DELETE RESTRICT` para conservar referencias clínicas y administrativas. `CASCADE` se utiliza en contactos, horarios y tablas puente dependientes. En los subtipos de factura se deben eliminar primero las filas hijas antes de eliminar la línea principal.

InnoDB exige índices para sus claves foráneas y crea los índices de las columnas hijas cuando falta uno adecuado. Los índices explícitos del proyecto también cubren consultas frecuentes y restricciones de unicidad.

## 7. Vistas disponibles

| Vista | Resultado |
|---|---|
| `v_peso_actual_mascota` | Último peso no nulo por mascota; desempata por `id_historia`. Incluye mascotas sin peso, con resultado nulo |
| `v_estado_recordatorio` | Estado del recordatorio según cumplimiento y fecha actual |
| `v_stock_medicamento_sede` | Stock físico, vigente, vencido y comparación con el mínimo, incluso si no hay lotes |
| `v_detalle_factura_subtotal` | Concepto, subtotal de línea y señal `detalle_completo` |
| `v_hospitalizacion_estado` | Estado de la estancia calculado a partir de su salida |

En inventario, `stock_fisico` suma todos los lotes; `stock_actual` suma los que no han vencido y `stock_vencido` los vencidos. Un lote que vence hoy se considera vigente durante el día. `bajo_minimo` usa una comparación estricta: stock menor que mínimo. La condición `activo` permite filtrar los productos por sede.

## 8. Instalación

Se necesita un servidor MySQL 8.0.16 o superior y una cuenta con permisos para crear tablas y vistas. MySQL Workbench puede abrir y ejecutar el archivo. El script usa sintaxis propia de MySQL.

### Opción A: MySQL Workbench

1. Abrir una conexión al servidor.
2. Crear una base vacía y seleccionarla:

   ```sql
   CREATE DATABASE vet_db
     CHARACTER SET utf8mb4
     COLLATE utf8mb4_0900_ai_ci;
   USE vet_db;
   ```

3. Abrir `vet_db.sql` y ejecutar el archivo completo en esa base.
4. Consultar las tablas y vistas desde el panel del esquema.

### Opción B: cliente de MySQL

```bash
mysql -u root -p -e "CREATE DATABASE vet_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"
mysql -u root -p vet_db < vet_db.sql
```

Estos comandos de consola usan redirección de entrada de Bash o de CMD en Windows. En PowerShell puede utilizarse Workbench o abrir el cliente interactivo y ejecutar `USE vet_db;` seguido de `SOURCE C:/ruta/vet_db.sql;`.

El archivo se ejecuta una vez sobre una base vacía. No contiene borrados, migraciones ni reinicializaciones. MySQL confirma las operaciones DDL por separado; si la ejecución se interrumpe, pueden quedar objetos ya creados. Debe revisarse el error antes de continuar.

La aplicación debe configurar cada conexión con modo SQL estricto y la zona horaria acordada. La configuración de sesión del script solo afecta a la conexión que lo ejecuta. Los campos `TIMESTAMP` convierten entre UTC y la zona de sesión; las columnas `DATE` representan fechas de calendario.

### Orden de registro de datos

1. Catálogos, departamentos y ciudades.
2. Sedes y personas, con sus contactos.
3. Propietarios, personal, usuarios, mascotas y servicios.
4. Proveedores, productos, configuración por sede y lotes.
5. Citas, atenciones, antecedentes, jaulas y hospitalizaciones.
6. Tratamientos, vacunas, recordatorios y documentos.
7. Facturas, líneas con su subtipo y pagos.

## 9. Consultas de ejemplo

### Historial de una mascota

```sql
SELECT id_historia, fecha_atencion, motivo_consulta, diagnostico,
       peso_registrado
FROM historia_clinica
WHERE id_mascota = 1
ORDER BY fecha_atencion DESC, id_historia DESC;
```

### Recordatorios vencidos

```sql
SELECT id_recordatorio, id_mascota, id_servicio, fecha_proxima
FROM v_estado_recordatorio
WHERE estado = 'vencido'
ORDER BY fecha_proxima;
```

### Medicamentos que necesitan reposición

```sql
SELECT m.nombre, s.nombre AS sede, v.stock_actual,
       v.stock_vencido, v.stock_minimo
FROM v_stock_medicamento_sede AS v
JOIN medicamento AS m ON m.id_medicamento = v.id_medicamento
JOIN sede AS s ON s.id_sede = v.id_sede
WHERE v.activo = TRUE AND m.activo = TRUE AND v.bajo_minimo = TRUE;
```

### Detalles de una factura

```sql
SELECT tipo_item, nombre_item, cantidad, precio_unitario,
       subtotal_linea, detalle_completo
FROM v_detalle_factura_subtotal
WHERE id_factura = 1;
```

### Saldo calculado

```sql
SELECT f.id_factura, f.total,
       COALESCE(SUM(p.monto), 0) AS total_pagado,
       f.total - COALESCE(SUM(p.monto), 0) AS saldo
FROM factura AS f
LEFT JOIN pago AS p ON p.id_factura = f.id_factura
WHERE f.estado_pago <> 'anulada'
GROUP BY f.id_factura, f.total;
```

## 10. Alcance de las reglas de negocio

| Regla | Responsable |
|---|---|
| Existencia de propietarios, pacientes, profesionales y demás referencias | Claves foráneas del SQL |
| Coincidencia de mascota y servicio en las relaciones compuestas | Claves foráneas compuestas |
| Unicidad de documentos y combinaciones del catálogo | Restricciones `UNIQUE` |
| Importes, dosis y cantidades válidas; coherencia de fechas de salida | Restricciones `CHECK` |
| Un solo contacto principal por titular y canal | Aplicación; el indicador no tiene unicidad condicional |
| Agenda sin solapamientos y jaulas disponibles | Aplicación, con transacciones y control de concurrencia |
| Profesional autorizado y servicio adecuado para una vacunación | Aplicación |
| Vencimiento, sede del lote y descuento de inventario al consumir | Aplicación |
| Un subtipo obligatorio por línea y coherencia entre líneas y factura | Aplicación, en una misma transacción |
| Saldo, límite de abonos, estado de pago y protección de la factura emitida | Aplicación |
| Generación de recordatorios, envío de mensajes y videollamadas | Servicios de la aplicación |

## 11. Organización y normalización

El modelo separa catálogos, hechos clínicos, contactos y relaciones de varios valores. Las tablas puente representan relaciones N:M y las vistas calculan información que depende de otros registros.

El análisis completo se encuentra en [Normalizacion.md](Normalizacion.md). El diseño conserva redundancias deliberadas, como los importes de factura y el discriminador de los subtipos. Por ello, la normalización se explica por relación y por dependencia, sin atribuir una misma forma normal máxima a todo el esquema.

## 12. Referencias técnicas

- [MySQL: CREATE TABLE y definición del esquema](https://dev.mysql.com/doc/refman/8.0/en/create-table.html).
- [MySQL: claves foráneas y acciones referenciales](https://dev.mysql.com/doc/refman/8.0/en/create-table-foreign-keys.html).
- [MySQL: restricciones CHECK](https://docs.oracle.com/cd/E17952_01/mysql-8.0-en/create-table-check-constraints.html).

Las entidades, columnas y relaciones descritas corresponden al archivo `vet_db.sql` de este proyecto.
