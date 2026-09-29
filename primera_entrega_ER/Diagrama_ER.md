# Diagrama Entidad-Relación — Clínica Veterinaria

Modelo conceptual original (20 entidades, 32 relaciones), listo para renderizarse con **Mermaid** (GitHub, GitLab, Obsidian, VS Code con extensión Mermaid, <https://mermaid.live>).

Los atributos incluyen las llaves foráneas indicadas en el esquema de la actividad exploratoria (el PDF las omitía o las mostraba truncadas).

**Notación de cardinalidad**

| Símbolo | Significado |
| :-- | :-- |
| `\|\|--o{` | Uno a muchos (1:N) |
| `\|\|--o\|` | Uno a cero-o-uno (1:0..1) |
| `PK` / `FK` / `UK` | Llave primaria / foránea / única (no primaria) |

---

## 1. Diagrama general de entidades y relaciones

```mermaid
erDiagram
    SEDE ||--o{ MASCOTA : "ATIENDE"
    SEDE ||--o{ VETERINARIO : "ASIGNA"
    SEDE ||--o{ CITA : "AGENDA"
    SEDE ||--o{ MEDICAMENTO : "ADMINISTRA"
    SEDE ||--o{ FACTURA : "EMITE"
    SEDE ||--o{ HOSPITALIZACION : "ALOJA"

    PROPIETARIO ||--o{ MASCOTA : "POSEE"
    PROPIETARIO ||--o{ FACTURA : "RECIBE"

    MASCOTA ||--o{ CITA : "TIENE_CITA"
    MASCOTA ||--o{ HISTORIA_CLINICA : "GENERA_HISTORIA"
    MASCOTA ||--o{ VACUNACION_RECORDATORIO : "TIENE_RECORDATORIO"
    MASCOTA ||--o{ ANTECEDENTE_MEDICO : "TIENE_ANTECEDENTE"
    MASCOTA ||--o{ HOSPITALIZACION : "SE_INTERNA"

    VETERINARIO ||--o| USUARIO : "ACCEDE"
    VETERINARIO ||--o{ HORARIO_VETERINARIO : "TIENE_HORARIO"
    VETERINARIO ||--o{ CITA : "ATIENDE_CITA"
    VETERINARIO ||--o{ HISTORIA_CLINICA : "REGISTRA"
    VETERINARIO ||--o{ VACUNACION_RECORDATORIO : "APLICA"
    VETERINARIO ||--o{ DOCUMENTO : "CARGA"

    SERVICIO ||--o{ CITA : "SE_PROGRAMA"
    SERVICIO ||--o{ VACUNACION_RECORDATORIO : "GENERA_VACUNA"
    SERVICIO ||--o{ DETALLE_FACTURA : "SE_DETALLA"

    PROVEEDOR ||--o{ LOTE_MEDICAMENTO : "SUMINISTRA"

    CITA ||--o| HISTORIA_CLINICA : "ORIGINA_HISTORIA"

    HISTORIA_CLINICA ||--o{ DOCUMENTO : "ADJUNTA"
    HISTORIA_CLINICA ||--o{ TRATAMIENTO_MEDICAMENTO : "INCLUYE"
    HISTORIA_CLINICA ||--o| HOSPITALIZACION : "ORIGINA_INTERNAMIENTO"

    MEDICAMENTO ||--o{ LOTE_MEDICAMENTO : "SE_CONTROLA"
    MEDICAMENTO ||--o{ DETALLE_FACTURA : "SE_FACTURA"

    LOTE_MEDICAMENTO ||--o{ TRATAMIENTO_MEDICAMENTO : "SE_USA_EN"

    FACTURA ||--o{ DETALLE_FACTURA : "CONTIENE"
    FACTURA ||--o{ PAGO : "SE_SALDA"
```

---

## 2. Diagramas con atributos por módulo

### 2.1 Módulo Núcleo (Sede, Propietario, Mascota, Veterinario, Usuario, Horario)

```mermaid
erDiagram
    SEDE ||--o{ MASCOTA : "ATIENDE"
    SEDE ||--o{ VETERINARIO : "ASIGNA"
    PROPIETARIO ||--o{ MASCOTA : "POSEE"
    VETERINARIO ||--o| USUARIO : "ACCEDE"
    VETERINARIO ||--o{ HORARIO_VETERINARIO : "TIENE_HORARIO"

    SEDE {
        int id_sede PK
        varchar nombre
        varchar direccion
        varchar ciudad
        varchar telefono
        varchar email
        date fecha_apertura
    }

    PROPIETARIO {
        int id_propietario PK
        varchar tipo_documento
        varchar numero_documento
        varchar nombre
        varchar apellido
        varchar telefono
        varchar email
        varchar direccion
        date fecha_registro
    }

    MASCOTA {
        int id_mascota PK
        int id_propietario FK
        int id_sede FK
        varchar nombre
        varchar especie
        varchar raza
        date fecha_nacimiento
        char sexo "M / H"
        boolean esterilizado
        decimal peso_actual "kg"
        varchar numero_microchip
        varchar estado "Activo / Fallecido / Inactivo"
        date fecha_fallecimiento "solo si estado = Fallecido"
    }

    VETERINARIO {
        int id_veterinario PK
        int id_sede FK
        varchar tipo_documento
        varchar numero_documento
        varchar nombre
        varchar apellido
        varchar rol "Veterinario / Auxiliar / Recepcion"
        varchar especialidad
        varchar numero_licencia
        date fecha_ingreso
        boolean activo
    }

    USUARIO {
        int id_usuario PK
        int id_veterinario FK "opcional"
        varchar nombre_usuario
        varchar contrasena_hash
        varchar rol_sistema
        boolean activo
        datetime ultimo_acceso
        datetime fecha_creacion
    }

    HORARIO_VETERINARIO {
        int id_horario PK
        int id_veterinario FK
        int dia_semana "1 = Lunes ... 7 = Domingo"
        time hora_inicio
        time hora_fin
    }
```

### 2.2 Módulo Clínico (Cita, Historia clínica, Antecedente, Hospitalización, Documento, Vacunación)

```mermaid
erDiagram
    SEDE ||--o{ CITA : "AGENDA"
    SEDE ||--o{ HOSPITALIZACION : "ALOJA"
    MASCOTA ||--o{ CITA : "TIENE_CITA"
    MASCOTA ||--o{ HISTORIA_CLINICA : "GENERA_HISTORIA"
    MASCOTA ||--o{ VACUNACION_RECORDATORIO : "TIENE_RECORDATORIO"
    MASCOTA ||--o{ ANTECEDENTE_MEDICO : "TIENE_ANTECEDENTE"
    MASCOTA ||--o{ HOSPITALIZACION : "SE_INTERNA"
    VETERINARIO ||--o{ CITA : "ATIENDE_CITA"
    VETERINARIO ||--o{ HISTORIA_CLINICA : "REGISTRA"
    VETERINARIO ||--o{ VACUNACION_RECORDATORIO : "APLICA"
    VETERINARIO ||--o{ DOCUMENTO : "CARGA"
    SERVICIO ||--o{ CITA : "SE_PROGRAMA"
    SERVICIO ||--o{ VACUNACION_RECORDATORIO : "GENERA_VACUNA"
    CITA ||--o| HISTORIA_CLINICA : "ORIGINA_HISTORIA"
    HISTORIA_CLINICA ||--o{ DOCUMENTO : "ADJUNTA"
    HISTORIA_CLINICA ||--o| HOSPITALIZACION : "ORIGINA_INTERNAMIENTO"

    CITA {
        int id_cita PK
        int id_mascota FK
        int id_veterinario FK
        int id_servicio FK
        int id_sede FK
        datetime fecha_hora
        varchar canal "Presencial / Telemedicina"
        varchar url_videollamada "obligatorio si Telemedicina"
        varchar estado "Programada / Confirmada / Completada / Cancelada / No asistio"
        text observaciones
        boolean recordatorio_enviado
        datetime fecha_creacion
    }

    HISTORIA_CLINICA {
        int id_historia PK
        int id_mascota FK
        int id_cita FK "relacion 1:0..1"
        int id_veterinario FK
        datetime fecha_atencion
        text motivo_consulta
        text diagnostico
        text tratamiento_indicado
        decimal peso_registrado
        decimal temperatura
        date proxima_revision
    }

    ANTECEDENTE_MEDICO {
        int id_antecedente PK
        int id_mascota FK
        varchar tipo "Alergia / Enfermedad cronica / Cirugia previa / Otro"
        text descripcion
        varchar severidad "Leve / Moderada / Grave"
        date fecha_diagnostico
        boolean activo
    }

    HOSPITALIZACION {
        int id_hospitalizacion PK
        int id_mascota FK
        int id_historia FK "opcional"
        int id_sede FK
        varchar numero_jaula
        datetime fecha_ingreso
        datetime fecha_salida_estimada
        datetime fecha_salida_real
        text motivo
        varchar estado "Internado / Dado de alta / Trasladado / Fallecido"
    }

    DOCUMENTO {
        int id_documento PK
        int id_historia FK
        int id_veterinario FK
        varchar tipo_documento "Imagen / Resultado_lab / Consentimiento / Otro"
        varchar nombre_archivo
        varchar url_archivo
        datetime fecha_carga
    }

    VACUNACION_RECORDATORIO {
        int id_recordatorio PK
        int id_mascota FK
        int id_servicio FK
        int id_veterinario FK
        date fecha_aplicacion
        date fecha_proxima
        varchar lote_producto
        varchar estado "Pendiente / Aplicado / Vencido"
        boolean notificacion_enviada
    }
```

### 2.3 Módulo Inventario (Servicio, Proveedor, Medicamento, Lote, Tratamiento)

```mermaid
erDiagram
    SEDE ||--o{ MEDICAMENTO : "ADMINISTRA"
    PROVEEDOR ||--o{ LOTE_MEDICAMENTO : "SUMINISTRA"
    MEDICAMENTO ||--o{ LOTE_MEDICAMENTO : "SE_CONTROLA"
    LOTE_MEDICAMENTO ||--o{ TRATAMIENTO_MEDICAMENTO : "SE_USA_EN"
    HISTORIA_CLINICA ||--o{ TRATAMIENTO_MEDICAMENTO : "INCLUYE"
    SERVICIO ||--o{ CITA : "SE_PROGRAMA"
    SERVICIO ||--o{ VACUNACION_RECORDATORIO : "GENERA_VACUNA"
    SERVICIO ||--o{ DETALLE_FACTURA : "SE_DETALLA"
    MEDICAMENTO ||--o{ DETALLE_FACTURA : "SE_FACTURA"

    SERVICIO {
        int id_servicio PK
        varchar nombre
        varchar categoria "Consulta / Vacuna / Cirugia / Laboratorio / Imagen / Peluqueria / Hospitalizacion / Hotel"
        text descripcion
        decimal precio_base
        int duracion_estimada_min
        boolean requiere_periodicidad
        boolean activo
    }

    PROVEEDOR {
        int id_proveedor PK
        varchar nombre
        varchar nit UK
        varchar telefono
        varchar email
        varchar direccion
        boolean activo
    }

    MEDICAMENTO {
        int id_medicamento PK
        int id_sede FK
        varchar nombre
        varchar principio_activo
        varchar presentacion
        varchar laboratorio
        int stock_actual
        int stock_minimo
        decimal precio_unitario
        boolean activo
    }

    LOTE_MEDICAMENTO {
        int id_lote PK
        int id_medicamento FK
        int id_proveedor FK
        varchar numero_lote
        date fecha_vencimiento
        int cantidad_disponible
        date fecha_ingreso
    }

    TRATAMIENTO_MEDICAMENTO {
        int id_tratamiento_medicamento PK
        int id_historia FK
        int id_lote FK
        int cantidad_utilizada
        varchar dosis
        varchar frecuencia
        int duracion_dias
    }
```

### 2.4 Módulo Facturación (Factura, Detalle, Pago)

```mermaid
erDiagram
    SEDE ||--o{ FACTURA : "EMITE"
    PROPIETARIO ||--o{ FACTURA : "RECIBE"
    FACTURA ||--o{ DETALLE_FACTURA : "CONTIENE"
    FACTURA ||--o{ PAGO : "SE_SALDA"
    SERVICIO ||--o{ DETALLE_FACTURA : "SE_DETALLA"
    MEDICAMENTO ||--o{ DETALLE_FACTURA : "SE_FACTURA"

    FACTURA {
        int id_factura PK
        int id_propietario FK
        int id_sede FK
        datetime fecha_emision
        decimal subtotal
        decimal impuestos
        decimal total
        varchar estado_pago "Pendiente / Pagada / Anulada"
    }

    DETALLE_FACTURA {
        int id_detalle PK
        int id_factura FK
        int id_servicio FK "si aplica"
        int id_medicamento FK "si aplica"
        int cantidad
        decimal precio_unitario
        decimal subtotal "cantidad x precio_unitario"
    }

    PAGO {
        int id_pago PK
        int id_factura FK
        datetime fecha_pago
        decimal monto
        varchar medio_pago "Efectivo / Tarjeta / Transferencia / Otro"
        varchar referencia
    }
```

---

## 3. Catálogo de relaciones

| # | Origen | Destino | Cardinalidad | Nombre |
| :-- | :-- | :-- | :-- | :-- |
| 1 | Sede | Mascota | 1:N | ATIENDE |
| 2 | Sede | Veterinario | 1:N | ASIGNA |
| 3 | Sede | Cita | 1:N | AGENDA |
| 4 | Sede | Medicamento | 1:N | ADMINISTRA |
| 5 | Sede | Factura | 1:N | EMITE |
| 6 | Sede | Hospitalización | 1:N | ALOJA |
| 7 | Propietario | Mascota | 1:N | POSEE |
| 8 | Propietario | Factura | 1:N | RECIBE |
| 9 | Mascota | Cita | 1:N | TIENE_CITA |
| 10 | Mascota | Historia clínica | 1:N | GENERA_HISTORIA |
| 11 | Mascota | Vacunación/Recordatorio | 1:N | TIENE_RECORDATORIO |
| 12 | Mascota | Antecedente médico | 1:N | TIENE_ANTECEDENTE |
| 13 | Mascota | Hospitalización | 1:N | SE_INTERNA |
| 14 | Veterinario | Usuario | 1:0..1 | ACCEDE |
| 15 | Veterinario | Horario | 1:N | TIENE_HORARIO |
| 16 | Veterinario | Cita | 1:N | ATIENDE_CITA |
| 17 | Veterinario | Historia clínica | 1:N | REGISTRA |
| 18 | Veterinario | Vacunación/Recordatorio | 1:N | APLICA |
| 19 | Veterinario | Documento | 1:N | CARGA |
| 20 | Servicio | Cita | 1:N | SE_PROGRAMA |
| 21 | Servicio | Vacunación/Recordatorio | 1:N | GENERA_VACUNA |
| 22 | Servicio | Detalle factura | 1:N | SE_DETALLA |
| 23 | Proveedor | Lote medicamento | 1:N | SUMINISTRA |
| 24 | Cita | Historia clínica | 1:0..1 | ORIGINA_HISTORIA |
| 25 | Historia clínica | Documento | 1:N | ADJUNTA |
| 26 | Historia clínica | Tratamiento medicamento | 1:N | INCLUYE |
| 27 | Historia clínica | Hospitalización | 1:0..1 | ORIGINA_INTERNAMIENTO |
| 28 | Medicamento | Lote medicamento | 1:N | SE_CONTROLA |
| 29 | Medicamento | Detalle factura | 1:N | SE_FACTURA |
| 30 | Lote medicamento | Tratamiento medicamento | 1:N | SE_USA_EN |
| 31 | Factura | Detalle factura | 1:N | CONTIENE |
| 32 | Factura | Pago | 1:N | SE_SALDA |

> El modelo **normalizado** (34 tablas) está en `VET_Schema.dbml` y el proceso en `Normalizacion.md`.
