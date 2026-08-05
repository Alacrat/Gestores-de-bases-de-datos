# INFORME DE EXPLORACIÓN INICIAL
## Sistema de Gestión de una Clínica Veterinaria

*Diseño de base de datos relacional para la gestión integral de servicios de salud animal en clínicas veterinarias*

**Asignatura:** Bases de Datos Relacionales
**Actividad:** Consulta de exploración temática (Cuaderno digital del grupo)
**Fecha:** agosto de 2026

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

| Entidad | Rol dentro del sistema |
|---|---|
| Propietario / Cliente | Persona responsable de una o varias mascotas; datos de contacto, facturación y preferencias de comunicación. |
| Paciente / Mascota | Animal doméstico atendido: especie, raza, edad, peso, sexo, esterilización, identificación (chip). |
| Historia clínica | Registro cronológico de consultas, diagnósticos, tratamientos, exámenes y evolución del paciente. |
| Cita / Agenda | Programación de consultas, cirugías, procedimientos de peluquería u hospitalización. |
| Veterinario / Personal | Profesionales que prestan el servicio: médicos veterinarios, auxiliares, recepción. |
| Servicio / Procedimiento | Catálogo de consultas, vacunas, cirugías, exámenes de laboratorio, hospitalización, baño y peluquería. |
| Vacunación / Recordatorio | Control de periodicidad de vacunas y desparasitaciones, con alertas automáticas. |
| Inventario / Farmacia | Medicamentos, insumos y productos, con control de existencias y vencimientos. |
| Factura / Pago | Registro de cargos por servicios y productos, medios de pago y estado de cuenta. |

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

| Criterio | Provet Cloud (Nordhealth) | QVET |
|---|---|---|
| Origen / año | Finlandia (Finnish Net Solutions, hoy parte de Nordhealth) | España, con amplia trayectoria en el sector |
| Modelo de despliegue | 100% en la nube (SaaS), acceso desde cualquier dispositivo | Solución integral, con opciones multiusuario y multiempresa |
| Cobertura funcional | Agenda y reservas online, historiales clínicos, facturación, inventario, gestión de personal y turnos, telemedicina, portal y app para el propietario, recordatorios automáticos por email/SMS | Gestión de pacientes, citas, facturación, integración contable y con equipos de laboratorio, control multicentro |
| Escalabilidad | Clínicas pequeñas hasta hospitales y grupos veterinarios grandes; enfoque modular y personalizable | Clínicas, hospitales y grupos veterinarios de distintos tamaños |
| Integraciones | API abierta, integración bidireccional con equipos de diagnóstico y laboratorio, data warehouse (p. ej. Tableau) | Integración contable y con laboratorio |
| Modelo comercial | Suscripción mensual/periódica (SaaS), sin pago único de licencia | Licencia con actualizaciones automáticas |
| Aspecto destacado | Interfaz moderna, automatización de recordatorios y presupuestos, comunidad amplia (más de 2.900 clínicas) | Larga experiencia y presencia internacional; interfaz percibida como menos moderna |

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

## 6. Referencias consultadas

- Kings Research. Tamaño del mercado de software veterinario, participación y pronóstico.
- Mordor Intelligence. Tamaño y participación del mercado de software veterinario 2026-2031.
- Fortune Business Insights. Tamaño del mercado de telemedicina veterinaria.
- Animal's Health. Provet Cloud detalla cómo la IA está revolucionando la medicina veterinaria.
- SoftwareDoit. Provet Cloud: gestión para centros veterinarios.
- GetApp México. Provet: precios, funciones y opiniones.
- Provet Cloud. Software de gestión veterinaria — historiales clínicos y características.
- Provet.com Blog. Los 5 mejores software de gestión veterinaria.
- Iveter Blog. Tendencias en software veterinario para los próximos años.
- PUCV. Sistema de Gestión para Clínica Veterinaria (documento académico).
