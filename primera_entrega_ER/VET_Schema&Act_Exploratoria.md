## INFORME DE ACTIVIDAD EXPLORATORIA

## Sistema de Gestión de una Clínica Veterinaria

_Diseño de base de datos relacional para la gestión integral de servicios de salud animal en clínicas veterinarias_

**Asignatura:** Gestores de Bases de Datos
**Actividad:** Definición del diagrama E-R
**Integrantes:**

- Mateo Armando Sanguino Burgos - 01251151008
- Daniel Fernando Vesga Tarazona- 01251151006

---

## 1. Introducción

El presente informe recoge los resultados de la consulta de exploración inicial realizada por el grupo sobre la temática asignada: el diseño de una base de datos relacional para la gestión de una clínica veterinaria dedicada a animales domésticos. El objetivo de esta exploración es construir una base conceptual sólida antes de abordar el modelado entidad-relación y la posterior implementación del sistema, identificando los conceptos clave del dominio, las tendencias tecnológicas actuales y al menos dos herramientas ya existentes en el mercado que resuelven problemas similares.

Una clínica veterinaria de tamaño dinámico requiere un sistema capaz de crecer con el negocio: desde un consultorio pequeño con un único veterinario hasta una red de centros con múltiples sedes, especialidades y usuarios simultáneos. Esto exige que el modelo de datos sea flexible, normalizado y preparado para incorporar nuevos servicios sin comprometer la integridad de la información clínica y administrativa ya almacenada.

---

## 2. Conceptos importantes y relevantes

### 2.1 Conceptos del dominio veterinario

- **Historia clínica electrónica:** registro digital y cronológico de todas las atenciones de un paciente (diagnósticos, tratamientos, exámenes, evolución), que sustituye al expediente en papel y es el núcleo de cualquier sistema veterinario.
- **Paciente (mascota):** entidad central del sistema, caracterizada por especie, raza, edad, peso, sexo, estado reproductivo e identificación (por ejemplo, número de microchip).
- **Propietario o tutor:** persona responsable legal y económica de la mascota; puede tener varias mascotas asociadas (relación uno a muchos).
- **Servicios clínicos:** consultas, vacunación, desparasitación, cirugía, hospitalización, laboratorio, imágenes diagnósticas, peluquería y otros servicios complementarios (hotel, guardería).
- **Periodicidad y recordatorios:** ciertos servicios, como las vacunas, tienen una frecuencia definida que el sistema debe controlar para generar alertas automáticas de renovación.
- **Inventario y farmacia:** control de medicamentos e insumos, incluyendo existencias, lotes y fechas de vencimiento, vinculado a los tratamientos aplicados.
- **Facturación:** generación de comprobantes de cobro por servicios y productos, con trazabilidad hacia la historia clínica y el inventario.

### 2.2 Conceptos de bases de datos relacionales aplicados al dominio

- **Modelo entidad-relación (MER):** representación gráfica de las entidades del negocio (paciente, propietario, cita, veterinario, servicio) y de las relaciones y cardinalidades entre ellas, paso previo al modelo relacional.
- **Normalización:** proceso de organizar los datos en tablas para evitar redundancias e inconsistencias, típicamente hasta la tercera forma normal (3FN) en este tipo de sistemas.
- **Llaves primarias y foráneas:** mecanismos que garantizan la identificación única de cada registro y la integridad referencial entre tablas relacionadas, por ejemplo entre paciente y propietario.
- **Cardinalidad:** define cuántas instancias de una entidad se relacionan con otra, por ejemplo un propietario puede tener varias mascotas, y una mascota puede tener muchas citas a lo largo del tiempo.
- **Escalabilidad del esquema:** capacidad del diseño para incorporar nuevos servicios, sedes o roles de usuario sin rediseñar el modelo desde cero, lo que responde al requisito de "tamaño dinámico" del proyecto.

A modo de referencia, las siguientes son las entidades más recurrentes identificadas en la literatura y en proyectos similares consultados:

| Entidad                   | Rol dentro del sistema                                                                                       |
| ------------------------- | ------------------------------------------------------------------------------------------------------------ |
| Propietario / Cliente     | Persona responsable de una o varias mascotas; datos de contacto, facturación y preferencias de comunicación. |
| Paciente / Mascota        | Animal doméstico atendido: especie, raza, edad, peso, sexo, esterilización, identificación (chip).           |
| Historia clínica          | Registro cronológico de consultas, diagnósticos, tratamientos, exámenes y evolución del paciente.            |
| Cita / Agenda             | Programación de consultas, cirugías, procedimientos de peluquería u hospitalización.                         |
| Veterinario / Personal    | Profesionales que prestan el servicio: médicos veterinarios, auxiliares, recepción.                          |
| Servicio / Procedimiento  | Catálogo de consultas, vacunas, cirugías, exámenes de laboratorio, hospitalización, baño y peluquería.       |
| Vacunación / Recordatorio | Control de periodicidad de vacunas y desparasitaciones, con alertas automáticas.                             |
| Inventario / Farmacia     | Medicamentos, insumos y productos, con control de existencias y vencimientos.                                |
| Factura / Pago            | Registro de cargos por servicios y productos, medios de pago y estado de cuenta.                             |

---

## 3. Tendencias actuales

La investigación de mercado confirma que el software veterinario está en pleno crecimiento y transformación tecnológica. A continuación se resumen las tendencias más relevantes identificadas:

- **Migración hacia la nube (SaaS):** los sistemas instalados en un único computador están quedando atrás en favor de plataformas accesibles desde cualquier dispositivo, con trabajo en tiempo real entre el personal de la clínica y copias de seguridad automáticas.
- **Inteligencia artificial aplicada al diagnóstico y a la gestión:** el mercado incorpora cada vez más algoritmos de IA para analizar historiales, imágenes diagnósticas y resultados de laboratorio, apoyar la detección temprana de riesgos, generar resúmenes automáticos de historiales clínicos y sugerir controles preventivos según raza y edad.
- **Telemedicina veterinaria:** el mercado global de telesalud veterinaria mantiene un crecimiento sostenido, impulsado por la conveniencia para los propietarios y la posibilidad de realizar cribados iniciales mediante chatbots o el análisis remoto de imágenes.
- **Atención preventiva por suscripción:** las clínicas están adoptando modelos de planes de salud recurrentes, lo que exige que el sistema gestione ciclos de pago periódicos y recordatorios automatizados vinculados a estos planes.
- **Automatización de tareas administrativas:** recordatorios inteligentes de citas y vacunas, generación automática de presupuestos, análisis predictivo del stock de medicamentos y firma electrónica de consentimientos informados.
- **Interoperabilidad y APIs abiertas:** integración bidireccional con equipos de laboratorio y diagnóstico por imagen, así como con herramientas externas de analítica de negocio.

En conjunto, estas tendencias confirman que un diseño de base de datos moderno para una clínica veterinaria debe contemplar, desde el modelo relacional, la posibilidad de registrar consultas remotas, historiales enriquecidos con archivos multimedia, planes de salud recurrentes y trazas de auditoría para procesos automatizados.

---

## 4. Análisis de herramientas existentes en el mercado

Se seleccionaron dos soluciones de software de gestión veterinaria ampliamente utilizadas y documentadas, que representan enfoques comparables al problema planteado en el proyecto de clase.

### 4.1 Provet Cloud (Nordhealth)

Provet Cloud es un sistema de gestión de prácticas veterinarias basado en la nube, utilizado por más de 2.900 clínicas veterinarias. Está dirigido a clínicas de todos los tamaños, incluyendo hospitales y grupos veterinarios con múltiples sedes, lo que lo convierte en un referente directo para el requisito de "tamaño dinámico" del proyecto.

Entre sus funcionalidades principales se encuentran la agenda y reservas de citas en línea, la gestión de historiales clínicos centralizados (datos del cliente, historial del paciente, facturas, pruebas de laboratorio e imágenes en una sola vista), la administración de inventario y precios por centro, la programación de turnos del personal, la generación de presupuestos de tratamientos, el envío automático de recordatorios por correo y SMS, herramientas de telemedicina y una app móvil para los propietarios. Además ofrece una API abierta y exportación de datos hacia herramientas externas de analítica de negocio.

### 4.2 QVET

QVET es un software de gestión integral de origen español, con una trayectoria consolidada y presencia en más de 20 países, utilizado tanto por clínicas veterinarias independientes como por hospitales universitarios. Ofrece una solución completa para la gestión de pacientes, citas, facturación e inventario.

Se distingue por su enfoque multiusuario y multiempresa, que permite administrar varios centros desde una misma instalación, así como por su integración contable y con equipos de laboratorio. También incorpora módulos de marketing para la comunicación con clientes vía SMS y correo electrónico. Su interfaz es percibida por algunos usuarios como menos moderna que la de plataformas nativas en la nube más recientes, aspecto a considerar en el diseño de la experiencia de usuario del proyecto.

### 4.3 Cuadro comparativo

| Criterio             | Provet Cloud (Nordhealth)                                                                                                                                                                      | QVET                                                                                                             |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Origen / año         | Finlandia (Finnish Net Solutions, hoy parte de Nordhealth)                                                                                                                                     | España, con amplia trayectoria en el sector                                                                      |
| Modelo de despliegue | 100% en la nube (SaaS), acceso desde cualquier dispositivo                                                                                                                                     | Solución integral, con opciones multiusuario y multiempresa                                                      |
| Cobertura funcional  | Agenda y reservas online, historiales clínicos, facturación, inventario, gestión de personal y turnos, telemedicina, portal y app para el propietario, recordatorios automáticos por email/SMS | Gestión de pacientes, citas, facturación, integración contable y con equipos de laboratorio, control multicentro |
| Escalabilidad        | Clínicas pequeñas hasta hospitales y grupos veterinarios grandes; enfoque modular y personalizable                                                                                             | Clínicas, hospitales y grupos veterinarios de distintos tamaños                                                  |
| Integraciones        | API abierta, integración bidireccional con equipos de diagnóstico y laboratorio, data warehouse (p. ej. Tableau)                                                                               | Integración contable y con laboratorio                                                                           |
| Modelo comercial     | Suscripción mensual/periódica (SaaS), sin pago único de licencia                                                                                                                               | Licencia con actualizaciones automáticas                                                                         |
| Aspecto destacado    | Interfaz moderna, automatización de recordatorios y presupuestos, comunidad amplia (más de 2.900 clínicas)                                                                                     | Larga experiencia y presencia internacional; interfaz percibida como menos moderna                               |

### 4.4 Aprendizajes para el diseño de la base de datos

- El modelo debe soportar múltiples sedes o centros (multiempresa), aunque el proyecto inicie con una sola clínica, para no limitar el crecimiento futuro.
- La historia clínica debe permitir adjuntar archivos (imágenes, resultados de laboratorio, formularios firmados), lo que sugiere una tabla de documentos asociada al paciente o a la consulta.
- Los recordatorios y la periodicidad de vacunación deben modelarse como una entidad independiente vinculada al servicio y al paciente, para automatizar las alertas.
- La facturación debe integrarse con el inventario y los servicios prestados, garantizando trazabilidad entre lo clínico y lo administrativo.
- Debe preverse una entidad de "citas" desacoplada del canal (presencial o telemedicina), dado el crecimiento de las consultas remotas.

---

## 5. Conclusiones

La exploración inicial permitió identificar los conceptos fundamentales del dominio veterinario y su correspondencia con las entidades típicas de un modelo relacional (propietarios, pacientes, citas, historias clínicas, servicios, inventario y facturación). Asimismo, se evidenció que el mercado avanza hacia soluciones en la nube, con incorporación creciente de inteligencia artificial y telemedicina, lo que representa oportunidades de mejora respecto a los sistemas veterinarios tradicionales basados en archivos locales o en papel.

El análisis comparativo de Provet Cloud y QVET confirma que, si bien ambas herramientas cubren necesidades similares, difieren en su modelo de despliegue, su enfoque de escalabilidad y su nivel de automatización. Estos hallazgos serán la base para definir los requerimientos funcionales y el modelo entidad-relación del sistema que el grupo diseñará en las siguientes etapas del proyecto.

---

# DIAGRAMA E-R

---

## 2. Entidades y atributos

### Sede

Representa cada centro o consultorio de la clínica, permitiendo el modelo multiempresa/multicentro identificado como aprendizaje clave del mercado.

| Atributo       | Descripción                    |
| :------------- | :----------------------------- |
| id_sede        | Identificador único de la sede |
| nombre         | Nombre comercial de la sede    |
| direccion      | Dirección física               |
| ciudad         | Ciudad donde opera             |
| telefono       | Teléfono de contacto           |
| email          | Correo de contacto             |
| fecha_apertura | Fecha de apertura de la sede   |

### Propietario

Persona responsable legal y económica de una o varias mascotas.

| Atributo         | Descripción                         |
| :--------------- | :---------------------------------- |
| id_propietario   | Identificador único del propietario |
| tipo_documento   | Tipo de documento de identidad      |
| numero_documento | Número de identificación            |
| nombre           | Nombres del propietario             |
| apellido         | Apellidos del propietario           |
| telefono         | Teléfono de contacto                |
| email            | Correo electrónico                  |
| direccion        | Dirección de residencia             |
| fecha_registro   | Fecha de alta en el sistema         |

### Mascota (Paciente)

Entidad central del sistema; animal doméstico atendido por la clínica.

| Atributo            | Descripción                                                |
| :------------------ | :--------------------------------------------------------- |
| id_mascota          | Identificador único de la mascota                          |
| id_propietario      | Tutor responsable                                          |
| id_sede             | Sede principal de atención                                 |
| nombre              | Nombre de la mascota                                       |
| especie             | Especie (canino, felino, ave, etc.)                        |
| raza                | Raza de la mascota                                         |
| fecha_nacimiento    | Fecha de nacimiento estimada o real                        |
| sexo                | M / H                                                      |
| esterilizado        | Estado reproductivo                                        |
| peso_actual         | Último peso registrado (kg)                                |
| numero_microchip    | Identificación electrónica                                 |
| estado              | Activo / Fallecido / Inactivo                              |
| fecha_fallecimiento | Fecha de defunción; obligatoria solo si estado = Fallecido |

### Veterinario (Personal)

Profesionales que prestan los servicios: veterinarios, auxiliares y recepción.

| Atributo         | Descripción                                                                                        |
| :--------------- | :------------------------------------------------------------------------------------------------- |
| id_veterinario   | Identificador único del empleado                                                                   |
| id_sede          | Sede a la que está asignado                                                                        |
| tipo_documento   | Tipo de documento de identidad                                                                     |
| numero_documento | Número de identificación                                                                           |
| nombre           | Nombres                                                                                            |
| apellido         | Apellidos                                                                                          |
| rol              | Veterinario / Auxiliar / Recepción                                                                 |
| especialidad     | Especialidad clínica (si aplica)                                                                   |
| numero_licencia  | Registro profesional                                                                               |
| fecha_ingreso    | Fecha de ingreso a la clínica                                                                      |
| activo           | Permite dar de baja al empleado sin perder el historial de citas/historias clínicas que referencia |

### Usuario

Credenciales de acceso al sistema. Se separa de `Veterinario` porque no todo el personal con ficha clínica tiene acceso al sistema, y puede existir un usuario administrador puramente técnico sin ficha de personal.

| Atributo        | Descripción                                              |
| :-------------- | :------------------------------------------------------- |
| id_usuario      | Identificador único del usuario                          |
| id_veterinario  | Empleado asociado a esta cuenta, si aplica               |
| nombre_usuario  | Nombre de usuario para inicio de sesión                  |
| contrasena_hash | Hash de la contraseña (nunca se almacena en texto plano) |
| rol_sistema     | Administrador / Veterinario / Auxiliar / Recepción       |
| activo          | Habilita o bloquea el acceso                             |
| ultimo_acceso   | Fecha y hora del último inicio de sesión                 |
| fecha_creacion  | Fecha de creación de la cuenta                           |

### HorarioVeterinario

Disponibilidad semanal de cada profesional, necesaria para validar la agenda de citas (evitar programar fuera del horario laboral o duplicar turnos).

| Atributo       | Descripción                                  |
| :------------- | :------------------------------------------- |
| id_horario     | Identificador único del bloque de horario    |
| id_veterinario | Profesional al que pertenece el horario      |
| dia_semana     | Día de la semana (1 = Lunes ... 7 = Domingo) |
| hora_inicio    | Hora de inicio del turno                     |
| hora_fin       | Hora de fin del turno                        |

### AntecedenteMedico

Alergias, enfermedades crónicas y cirugías previas de la mascota. Es información de seguridad clínica que debe consultarse antes de indicar cualquier tratamiento o medicamento, y que en el modelo original no tenía un lugar propio (quedaba diluida como texto libre dentro de `HistoriaClinica`).

| Atributo          | Descripción                                           |
| :---------------- | :---------------------------------------------------- |
| id_antecedente    | Identificador único del antecedente                   |
| id_mascota        | Mascota a la que pertenece                            |
| tipo              | Alergia / Enfermedad crónica / Cirugía previa / Otro  |
| descripcion       | Detalle del antecedente (ej. "alérgico a penicilina") |
| severidad         | Leve / Moderada / Grave                               |
| fecha_diagnostico | Fecha en que se identificó el antecedente             |
| activo            | Indica si el antecedente sigue vigente                |

### Servicio (Catálogo)

Catálogo de consultas, vacunas, cirugías, exámenes, hospitalización, peluquería, hotel, etc.

| Atributo              | Descripción                                                                               |
| :-------------------- | :---------------------------------------------------------------------------------------- |
| id_servicio           | Identificador único del servicio                                                          |
| nombre                | Nombre del servicio                                                                       |
| categoria             | Consulta / Vacuna / Cirugía / Laboratorio / Imagen / Peluquería / Hospitalización / Hotel |
| descripcion           | Descripción detallada                                                                     |
| precio_base           | Precio de referencia                                                                      |
| duracion_estimada_min | Duración estimada en minutos                                                              |
| requiere_periodicidad | Indica si genera recordatorios (ej. vacunas)                                              |
| activo                | Permite descontinuar un servicio sin afectar citas/facturas históricas                    |

### Proveedor

Suministradores de medicamentos e insumos. El modelo original no tenía trazabilidad de origen para el inventario, un requisito básico de cualquier farmacia/bodega.

| Atributo     | Descripción                              |
| :----------- | :--------------------------------------- |
| id_proveedor | Identificador único del proveedor        |
| nombre       | Razón social o nombre comercial          |
| nit          | Identificación tributaria                |
| telefono     | Teléfono de contacto                     |
| email        | Correo de contacto                       |
| direccion    | Dirección                                |
| activo       | Indica si sigue siendo proveedor vigente |

### Medicamento (Inventario / Farmacia)

Catálogo de medicamentos e insumos gestionados por sede.

| Atributo         | Descripción                                            |
| :--------------- | :----------------------------------------------------- |
| id_medicamento   | Identificador único del medicamento                    |
| id_sede          | Sede donde se almacena                                 |
| nombre           | Nombre comercial                                       |
| principio_activo | Principio activo                                       |
| presentacion     | Presentación (tableta, ampolla, etc.)                  |
| laboratorio      | Laboratorio fabricante                                 |
| stock_actual     | Existencias actuales                                   |
| stock_minimo     | Umbral para alertas de reposición                      |
| precio_unitario  | Precio de venta unitario                               |
| activo           | Permite descontinuar un producto sin afectar historial |

### LoteMedicamento

Control de lotes y fechas de vencimiento por medicamento, requisito explícito del dominio.

| Atributo            | Descripción                      |
| :------------------ | :------------------------------- |
| id_lote             | Identificador único del lote     |
| id_medicamento      | Medicamento al que pertenece     |
| id_proveedor        | Proveedor que suministró el lote |
| numero_lote         | Número de lote del fabricante    |
| fecha_vencimiento   | Fecha de caducidad               |
| cantidad_disponible | Unidades disponibles de ese lote |
| fecha_ingreso       | Fecha de ingreso a inventario    |

### Cita (Agenda)

Programación de consultas, cirugías, peluquería, hospitalización o telemedicina, desacoplada del canal de atención.

| Atributo             | Descripción                                                    |
| :------------------- | :------------------------------------------------------------- |
| id_cita              | Identificador único de la cita                                 |
| id_mascota           | Paciente atendido                                              |
| id_veterinario       | Profesional asignado                                           |
| id_servicio          | Servicio programado                                            |
| id_sede              | Sede donde se agenda                                           |
| fecha_hora           | Fecha y hora programada                                        |
| canal                | Presencial / Telemedicina                                      |
| url_videollamada     | Enlace de la videollamada; obligatorio si canal = Telemedicina |
| estado               | Programada / Confirmada / Completada / Cancelada / No asistió  |
| observaciones        | Notas adicionales                                              |
| recordatorio_enviado | Indica si ya se notificó al propietario sobre la cita próxima  |
| fecha_creacion       | Fecha de creación del registro                                 |

### HistoriaClinica

Registro cronológico de cada atención: diagnóstico, tratamiento y evolución del paciente. Núcleo clínico del sistema.

| Atributo             | Descripción                                    |
| :------------------- | :--------------------------------------------- |
| id_historia          | Identificador único de la atención             |
| id_mascota           | Paciente atendido                              |
| id_cita              | Cita que originó la atención (relación 1:0..1) |
| id_veterinario       | Profesional que atendió                        |
| fecha_atencion       | Fecha y hora de la atención                    |
| motivo_consulta      | Motivo referido                                |
| diagnostico          | Diagnóstico clínico                            |
| tratamiento_indicado | Tratamiento prescrito                          |
| peso_registrado      | Peso en el momento de la atención              |
| temperatura          | Temperatura corporal registrada                |
| proxima_revision     | Fecha sugerida de control                      |

### Hospitalizacion

Control de internamiento (categorías de servicio `Hospitalización` y `Hotel`), que en el modelo original no tenían ninguna tabla que registrara jaula/box asignado, fechas de ingreso/salida o el estado de la estancia.

| Atributo              | Descripción                                              |
| :-------------------- | :------------------------------------------------------- |
| id_hospitalizacion    | Identificador único de la estancia                       |
| id_mascota            | Paciente internado                                       |
| id_historia           | Atención clínica que originó el internamiento, si aplica |
| id_sede               | Sede donde permanece internada la mascota                |
| numero_jaula          | Identificador del box/jaula asignado                     |
| fecha_ingreso         | Fecha y hora de ingreso                                  |
| fecha_salida_estimada | Fecha estimada de alta                                   |
| fecha_salida_real     | Fecha real de alta                                       |
| motivo                | Motivo del internamiento                                 |
| estado                | Internado / Dado de alta / Trasladado / Fallecido        |

### Documento

Archivos adjuntos a una atención clínica: imágenes, resultados de laboratorio o consentimientos firmados.

| Atributo       | Descripción                                    |
| :------------- | :--------------------------------------------- |
| id_documento   | Identificador único del documento              |
| id_historia    | Atención a la que pertenece                    |
| id_veterinario | Quién cargó el documento                       |
| tipo_documento | Imagen / Resultado_lab / Consentimiento / Otro |
| nombre_archivo | Nombre original del archivo                    |
| url_archivo    | Ruta o URL de almacenamiento                   |
| fecha_carga    | Fecha de carga al sistema                      |

### VacunacionRecordatorio

Control de periodicidad de vacunas y desparasitaciones, con generación de alertas automáticas.

| Atributo             | Descripción                             |
| :------------------- | :-------------------------------------- |
| id_recordatorio      | Identificador único del recordatorio    |
| id_mascota           | Paciente asociado                       |
| id_servicio          | Vacuna o servicio periódico             |
| id_veterinario       | Quien aplicó el servicio                |
| fecha_aplicacion     | Fecha en que se aplicó                  |
| fecha_proxima        | Fecha sugerida de renovación            |
| lote_producto        | Lote de la vacuna aplicada              |
| estado               | Pendiente / Aplicado / Vencido          |
| notificacion_enviada | Indica si ya se notificó al propietario |

### TratamientoMedicamento

Detalle de los medicamentos aplicados o prescritos dentro de una atención clínica, vinculando el tratamiento con el inventario.

| Atributo                   | Descripción                         |
| :------------------------- | :---------------------------------- |
| id_tratamiento_medicamento | Identificador único del registro    |
| id_historia                | Atención asociada                   |
| id_lote                    | Lote del medicamento utilizado      |
| cantidad_utilizada         | Unidades administradas o prescritas |
| dosis                      | Dosis indicada                      |
| frecuencia                 | Frecuencia de administración        |
| duracion_dias              | Duración del tratamiento en días    |

### Factura

Comprobante de cobro por servicios y productos, vinculado al propietario y a la sede.

| Atributo       | Descripción                       |
| :------------- | :-------------------------------- |
| id_factura     | Identificador único de la factura |
| id_propietario | Cliente facturado                 |
| id_sede        | Sede que emite la factura         |
| fecha_emision  | Fecha de emisión                  |
| subtotal       | Subtotal antes de impuestos       |
| impuestos      | Valor de impuestos aplicados      |
| total          | Valor total a pagar               |
| estado_pago    | Pendiente / Pagada / Anulada      |

### DetalleFactura

Líneas de detalle de la factura, permitiendo trazabilidad hacia servicios prestados y/o medicamentos vendidos.

| Atributo        | Descripción                     |
| :-------------- | :------------------------------ |
| id_detalle      | Identificador único del detalle |
| id_factura      | Factura a la que pertenece      |
| id_servicio     | Servicio facturado, si aplica   |
| id_medicamento  | Producto facturado, si aplica   |
| cantidad        | Cantidad facturada              |
| precio_unitario | Precio unitario aplicado        |
| subtotal        | cantidad × precio_unitario      |

### Pago

Registra cada transacción de pago sobre una factura, permitiendo abonos parciales y medios de pago combinados (ej. mitad efectivo, mitad tarjeta), algo que el campo único `medio_pago` de `Factura` no podía representar.

| Atributo   | Descripción                                              |
| :--------- | :------------------------------------------------------- |
| id_pago    | Identificador único del pago                             |
| id_factura | Factura a la que abona este pago                         |
| fecha_pago | Fecha y hora del pago                                    |
| monto      | Valor abonado en esta transacción                        |
| medio_pago | Efectivo / Tarjeta / Transferencia / Otro                |
| referencia | Número de aprobación, comprobante de transferencia, etc. |

---

## 3. Relaciones y cardinalidad

| #   | Entidad origen  | Entidad destino        | Cardinalidad | Descripción de la relación                                            |
| :-- | :-------------- | :--------------------- | :----------- | :-------------------------------------------------------------------- |
| 1   | Sede            | Mascota                | 1:N          | Una sede atiende muchas mascotas como sede principal                  |
| 2   | Sede            | Veterinario            | 1:N          | Una sede tiene asignado varios miembros del personal                  |
| 3   | Sede            | Cita                   | 1:N          | Una sede agenda muchas citas                                          |
| 4   | Sede            | Medicamento            | 1:N          | Una sede administra su propio inventario                              |
| 5   | Sede            | Factura                | 1:N          | Una sede emite muchas facturas                                        |
| 6   | Sede            | Hospitalizacion        | 1:N          | Una sede aloja muchos internamientos                                  |
| 7   | Propietario     | Mascota                | 1:N          | Un propietario puede tener varias mascotas                            |
| 8   | Propietario     | Factura                | 1:N          | Un propietario recibe varias facturas a lo largo del tiempo           |
| 9   | Mascota         | Cita                   | 1:N          | Una mascota puede tener muchas citas                                  |
| 10  | Mascota         | HistoriaClinica        | 1:N          | Una mascota acumula muchos registros clínicos                         |
| 11  | Mascota         | VacunacionRecordatorio | 1:N          | Una mascota tiene muchos recordatorios de vacunación                  |
| 12  | Mascota         | AntecedenteMedico      | 1:N          | Una mascota puede tener varios antecedentes/alergias                  |
| 13  | Mascota         | Hospitalizacion        | 1:N          | Una mascota puede tener varios internamientos a lo largo del tiempo   |
| 14  | Veterinario     | Usuario                | 1:0..1       | Un empleado puede tener, como máximo, una cuenta de acceso al sistema |
| 15  | Veterinario     | HorarioVeterinario     | 1:N          | Un profesional tiene varios bloques de horario semanal                |
| 16  | Veterinario     | Cita                   | 1:N          | Un veterinario atiende muchas citas                                   |
| 17  | Veterinario     | HistoriaClinica        | 1:N          | Un veterinario registra muchas historias clínicas                     |
| 18  | Veterinario     | VacunacionRecordatorio | 1:N          | Un veterinario aplica muchos recordatorios/vacunas                    |
| 19  | Veterinario     | Documento              | 1:N          | Un veterinario carga muchos documentos                                |
| 20  | Servicio        | Cita                   | 1:N          | Un servicio se programa en muchas citas                               |
| 21  | Servicio        | VacunacionRecordatorio | 1:N          | Un servicio (vacuna) genera muchos recordatorios                      |
| 22  | Servicio        | DetalleFactura         | 1:N          | Un servicio aparece en muchos detalles de factura                     |
| 23  | Proveedor       | LoteMedicamento        | 1:N          | Un proveedor suministra muchos lotes                                  |
| 24  | Cita            | HistoriaClinica        | 1:0..1       | Una cita puede originar, como máximo, una historia clínica            |
| 25  | HistoriaClinica | Documento              | 1:N          | Una historia clínica puede tener varios documentos adjuntos           |
| 26  | HistoriaClinica | TratamientoMedicamento | 1:N          | Una historia clínica puede incluir varios medicamentos aplicados      |
| 27  | HistoriaClinica | Hospitalizacion        | 1:0..1       | Una historia clínica puede originar, como máximo, un internamiento    |
| 28  | Medicamento     | LoteMedicamento        | 1:N          | Un medicamento se controla en varios lotes                            |
| 29  | Medicamento     | DetalleFactura         | 1:N          | Un medicamento se factura en varias líneas de detalle                 |
| 30  | LoteMedicamento | TratamientoMedicamento | 1:N          | Un lote específico puede usarse en varios tratamientos                |
| 31  | Factura         | DetalleFactura         | 1:N          | Una factura contiene muchas líneas de detalle                         |
| 32  | Factura         | Pago                   | 1:N          | Una factura puede saldarse mediante varios pagos/abonos               |

---
