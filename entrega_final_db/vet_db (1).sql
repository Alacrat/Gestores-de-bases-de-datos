-- BASE DE DATOS PARA UNA CLINICA VETERINARIA
-- Motor: MySQL 8.0.16 o superior, InnoDB. Compatible con MySQL 8.4.
-- Ejecutar una sola vez dentro de una base de datos vacia ya seleccionada.
-- Este archivo crea el esquema y las vistas. No inserta datos de ejemplo.
-- Las fechas TIMESTAMP se interpretan en la zona horaria de la conexion.

SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;
SET SESSION time_zone = '-05:00';
SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- 01. departamento
CREATE TABLE `departamento` (
  `id_departamento` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(80) UNIQUE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 02. ciudad
CREATE TABLE `ciudad` (
  `id_ciudad` integer PRIMARY KEY AUTO_INCREMENT,
  `id_departamento` integer NOT NULL,
  `nombre` varchar(80) NOT NULL,
  UNIQUE KEY `uq_ciudad_departamento_nombre` (`id_departamento`, `nombre`),
  CONSTRAINT `fk_ciudad_departamento` FOREIGN KEY (`id_departamento`) REFERENCES `departamento` (`id_departamento`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 03. tipo_documento_identidad
CREATE TABLE `tipo_documento_identidad` (
  `id_tipo_documento` smallint PRIMARY KEY AUTO_INCREMENT,
  `codigo` varchar(10) UNIQUE NOT NULL COMMENT 'CC, CE, TI, PAS, NIT...',
  `nombre` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 04. rol
CREATE TABLE `rol` (
  `id_rol` smallint PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(40) UNIQUE NOT NULL COMMENT 'administrador, veterinario, auxiliar, recepcion...'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 05. especie
CREATE TABLE `especie` (
  `id_especie` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(60) UNIQUE NOT NULL COMMENT 'Canino, felino, ave...'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 06. raza
CREATE TABLE `raza` (
  `id_raza` integer PRIMARY KEY AUTO_INCREMENT,
  `id_especie` integer NOT NULL,
  `nombre` varchar(80) NOT NULL COMMENT 'Raza de una especie. Se puede registrar Sin raza definida por especie',
  UNIQUE KEY `uq_raza_especie_nombre` (`id_especie`, `nombre`),
  CONSTRAINT `fk_raza_especie` FOREIGN KEY (`id_especie`) REFERENCES `especie` (`id_especie`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 07. especialidad
CREATE TABLE `especialidad` (
  `id_especialidad` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(80) UNIQUE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 08. categoria_servicio
CREATE TABLE `categoria_servicio` (
  `id_categoria` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(60) UNIQUE NOT NULL COMMENT 'Consulta, Vacuna, Cirugía, Laboratorio, Imagen, Peluquería, Hospitalización, Hotel'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 09. laboratorio
CREATE TABLE `laboratorio` (
  `id_laboratorio` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(120) UNIQUE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 10. presentacion
CREATE TABLE `presentacion` (
  `id_presentacion` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(60) UNIQUE NOT NULL COMMENT 'Tableta, ampolla, jarabe...'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 11. principio_activo
CREATE TABLE `principio_activo` (
  `id_principio_activo` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(120) UNIQUE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 12. unidad_medida
CREATE TABLE `unidad_medida` (
  `id_unidad` integer PRIMARY KEY AUTO_INCREMENT,
  `simbolo` varchar(15) UNIQUE NOT NULL COMMENT 'mg, ml, UI, tableta, gota...',
  `nombre` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 13. medio_pago
CREATE TABLE `medio_pago` (
  `id_medio_pago` smallint PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(60) UNIQUE NOT NULL COMMENT 'Efectivo, tarjeta, transferencia...',
  `activo` boolean NOT NULL DEFAULT true,
  CONSTRAINT `ck_medio_pago_activo` CHECK (`activo` IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 14. sede
CREATE TABLE `sede` (
  `id_sede` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(120) UNIQUE NOT NULL,
  `direccion` varchar(200) NOT NULL,
  `id_ciudad` integer NOT NULL,
  `fecha_apertura` date,
  CONSTRAINT `fk_sede_ciudad` FOREIGN KEY (`id_ciudad`) REFERENCES `ciudad` (`id_ciudad`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 15. sede_telefono
CREATE TABLE `sede_telefono` (
  `id_sede` integer NOT NULL,
  `telefono` varchar(20) NOT NULL,
  `tipo` ENUM ('movil', 'fijo') NOT NULL DEFAULT 'fijo',
  `es_principal` boolean NOT NULL DEFAULT false,
  PRIMARY KEY (`id_sede`, `telefono`),
  CONSTRAINT `ck_sede_telefono_es_principal` CHECK (`es_principal` IN (0, 1)),
  CONSTRAINT `fk_sede_telefono` FOREIGN KEY (`id_sede`) REFERENCES `sede` (`id_sede`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 16. sede_email
CREATE TABLE `sede_email` (
  `id_sede` integer NOT NULL,
  `email` varchar(120) NOT NULL,
  `es_principal` boolean NOT NULL DEFAULT false,
  PRIMARY KEY (`id_sede`, `email`),
  CONSTRAINT `ck_sede_email_es_principal` CHECK (`es_principal` IN (0, 1)),
  CONSTRAINT `fk_sede_email` FOREIGN KEY (`id_sede`) REFERENCES `sede` (`id_sede`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 17. persona
CREATE TABLE `persona` (
  `id_persona` integer PRIMARY KEY AUTO_INCREMENT,
  `id_tipo_documento` smallint NOT NULL,
  `numero_documento` varchar(30) NOT NULL,
  `nombre` varchar(80) NOT NULL,
  `apellido` varchar(80) NOT NULL,
  `direccion` varchar(200),
  UNIQUE KEY `uq_persona_documento` (`id_tipo_documento`, `numero_documento`),
  CONSTRAINT `fk_persona_tipo_doc` FOREIGN KEY (`id_tipo_documento`) REFERENCES `tipo_documento_identidad` (`id_tipo_documento`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='Datos personales compartidos por propietarios y personal de la clinica';

-- 18. persona_telefono
CREATE TABLE `persona_telefono` (
  `id_persona` integer NOT NULL,
  `telefono` varchar(20) NOT NULL,
  `tipo` ENUM ('movil', 'fijo') NOT NULL DEFAULT 'movil',
  `es_principal` boolean NOT NULL DEFAULT false,
  PRIMARY KEY (`id_persona`, `telefono`),
  CONSTRAINT `ck_persona_telefono_es_principal` CHECK (`es_principal` IN (0, 1)),
  CONSTRAINT `fk_persona_telefono` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 19. persona_email
CREATE TABLE `persona_email` (
  `id_persona` integer NOT NULL,
  `email` varchar(120) NOT NULL,
  `es_principal` boolean NOT NULL DEFAULT false,
  PRIMARY KEY (`id_persona`, `email`),
  CONSTRAINT `ck_persona_email_es_principal` CHECK (`es_principal` IN (0, 1)),
  CONSTRAINT `fk_persona_email` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 20. propietario
CREATE TABLE `propietario` (
  `id_propietario` integer PRIMARY KEY AUTO_INCREMENT,
  `id_persona` integer UNIQUE NOT NULL,
  `fecha_registro` date NOT NULL DEFAULT (CURRENT_DATE),
  CONSTRAINT `fk_propietario_persona` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 21. mascota
CREATE TABLE `mascota` (
  `id_mascota` integer PRIMARY KEY AUTO_INCREMENT,
  `id_propietario` integer NOT NULL,
  `id_sede` integer NOT NULL COMMENT 'Sede principal de atención',
  `id_raza` integer NOT NULL COMMENT 'La especie se obtiene vía raza',
  `nombre` varchar(80) NOT NULL,
  `fecha_nacimiento` date,
  `sexo` ENUM ('M', 'H') NOT NULL,
  `esterilizado` boolean NOT NULL DEFAULT false,
  `numero_microchip` varchar(30) UNIQUE,
  `estado` ENUM ('activo', 'inactivo', 'fallecido') NOT NULL DEFAULT 'activo',
  `fecha_fallecimiento` date,
  CONSTRAINT `ck_mascota_fallecimiento` CHECK ((estado = 'fallecido') = (fecha_fallecimiento IS NOT NULL)),
  CONSTRAINT `ck_mascota_fechas` CHECK (fecha_fallecimiento IS NULL OR fecha_nacimiento IS NULL OR fecha_fallecimiento >= fecha_nacimiento),
  CONSTRAINT `ck_mascota_esterilizado` CHECK (`esterilizado` IN (0, 1)),
  KEY `idx_mascota_id_propietario` (`id_propietario`),
  KEY `idx_mascota_id_sede` (`id_sede`),
  KEY `idx_mascota_id_raza` (`id_raza`),
  CONSTRAINT `fk_mascota_propietario` FOREIGN KEY (`id_propietario`) REFERENCES `propietario` (`id_propietario`) ON DELETE RESTRICT,
  CONSTRAINT `fk_mascota_sede` FOREIGN KEY (`id_sede`) REFERENCES `sede` (`id_sede`) ON DELETE RESTRICT,
  CONSTRAINT `fk_mascota_raza` FOREIGN KEY (`id_raza`) REFERENCES `raza` (`id_raza`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='Paciente veterinario. Su especie se obtiene de la raza y su ultimo peso de la historia clinica';

-- 22. veterinario
CREATE TABLE `veterinario` (
  `id_veterinario` integer PRIMARY KEY AUTO_INCREMENT,
  `id_persona` integer UNIQUE NOT NULL,
  `id_sede` integer NOT NULL,
  `id_rol` smallint NOT NULL COMMENT 'Función laboral: veterinario, auxiliar, recepción',
  `numero_licencia` varchar(40) UNIQUE COMMENT 'Registro profesional (si aplica)',
  `fecha_ingreso` date NOT NULL,
  `activo` boolean NOT NULL DEFAULT true COMMENT 'Baja lógica: conserva el historial',
  CONSTRAINT `ck_veterinario_activo` CHECK (`activo` IN (0, 1)),
  KEY `idx_veterinario_id_sede` (`id_sede`),
  KEY `idx_veterinario_id_rol` (`id_rol`),
  CONSTRAINT `fk_veterinario_persona` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE RESTRICT,
  CONSTRAINT `fk_veterinario_sede` FOREIGN KEY (`id_sede`) REFERENCES `sede` (`id_sede`) ON DELETE RESTRICT,
  CONSTRAINT `fk_veterinario_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='Personal de la clinica clasificado por funcion laboral. La aplicacion autoriza quien puede atender';

-- 23. veterinario_especialidad
CREATE TABLE `veterinario_especialidad` (
  `id_veterinario` integer NOT NULL,
  `id_especialidad` integer NOT NULL,
  PRIMARY KEY (`id_veterinario`, `id_especialidad`),
  CONSTRAINT `fk_vetesp_veterinario` FOREIGN KEY (`id_veterinario`) REFERENCES `veterinario` (`id_veterinario`) ON DELETE CASCADE,
  CONSTRAINT `fk_vetesp_especialidad` FOREIGN KEY (`id_especialidad`) REFERENCES `especialidad` (`id_especialidad`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 24. usuario
CREATE TABLE `usuario` (
  `id_usuario` integer PRIMARY KEY AUTO_INCREMENT,
  `id_veterinario` integer UNIQUE COMMENT 'NULL para cuentas puramente técnicas',
  `id_rol` smallint NOT NULL COMMENT 'Rol de permisos en el sistema',
  `nombre_usuario` varchar(50) UNIQUE NOT NULL,
  `contrasena_hash` varchar(255) NOT NULL,
  `activo` boolean NOT NULL DEFAULT true,
  `ultimo_acceso` timestamp NULL DEFAULT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `ck_usuario_activo` CHECK (`activo` IN (0, 1)),
  CONSTRAINT `fk_usuario_veterinario` FOREIGN KEY (`id_veterinario`) REFERENCES `veterinario` (`id_veterinario`) ON DELETE RESTRICT,
  CONSTRAINT `fk_usuario_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 25. horario_veterinario
CREATE TABLE `horario_veterinario` (
  `id_horario` integer PRIMARY KEY AUTO_INCREMENT,
  `id_veterinario` integer NOT NULL,
  `dia_semana` smallint NOT NULL COMMENT '1 = Lunes ... 7 = Domingo',
  `hora_inicio` time NOT NULL,
  `hora_fin` time NOT NULL,
  CONSTRAINT `ck_horario_dia` CHECK (dia_semana BETWEEN 1 AND 7),
  CONSTRAINT `ck_horario_rango` CHECK (hora_fin > hora_inicio),
  UNIQUE KEY `uq_horario_bloque` (`id_veterinario`, `dia_semana`, `hora_inicio`),
  CONSTRAINT `fk_horario_veterinario` FOREIGN KEY (`id_veterinario`) REFERENCES `veterinario` (`id_veterinario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 26. servicio
CREATE TABLE `servicio` (
  `id_servicio` integer PRIMARY KEY AUTO_INCREMENT,
  `id_categoria` integer NOT NULL,
  `nombre` varchar(120) UNIQUE NOT NULL,
  `descripcion` text,
  `precio_base` decimal(12,2) NOT NULL DEFAULT 0,
  `duracion_estimada_min` smallint,
  `periodicidad_dias` smallint COMMENT 'Intervalo orientativo en dias. NULL indica que el servicio no es periodico',
  `activo` boolean NOT NULL DEFAULT true,
  CONSTRAINT `ck_servicio_precio` CHECK (precio_base >= 0),
  CONSTRAINT `ck_servicio_periodicidad` CHECK (periodicidad_dias IS NULL OR periodicidad_dias > 0),
  CONSTRAINT `ck_servicio_duracion` CHECK (duracion_estimada_min IS NULL OR duracion_estimada_min > 0),
  CONSTRAINT `ck_servicio_activo` CHECK (`activo` IN (0, 1)),
  CONSTRAINT `fk_servicio_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria_servicio` (`id_categoria`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 27. cita
CREATE TABLE `cita` (
  `id_cita` integer PRIMARY KEY AUTO_INCREMENT,
  `id_mascota` integer NOT NULL,
  `id_veterinario` integer NOT NULL,
  `id_servicio` integer NOT NULL,
  `id_sede` integer NOT NULL,
  `fecha_hora` timestamp NOT NULL,
  `canal` ENUM ('presencial', 'telemedicina') NOT NULL DEFAULT 'presencial',
  `url_videollamada` varchar(500),
  `estado` ENUM ('programada', 'confirmada', 'completada', 'cancelada', 'no_asistio') NOT NULL DEFAULT 'programada',
  `observaciones` text,
  `recordatorio_enviado` boolean NOT NULL DEFAULT false,
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `ck_cita_videollamada` CHECK ((canal = 'telemedicina') = (url_videollamada IS NOT NULL)),
  CONSTRAINT `ck_cita_recordatorio_enviado` CHECK (`recordatorio_enviado` IN (0, 1)),
  UNIQUE KEY `uq_cita_id_mascota` (`id_cita`, `id_mascota`),
  KEY `idx_cita_id_mascota_fecha_hora` (`id_mascota`, `fecha_hora`),
  KEY `idx_cita_id_veterinario_fecha_hora` (`id_veterinario`, `fecha_hora`),
  KEY `idx_cita_id_sede_fecha_hora` (`id_sede`, `fecha_hora`),
  CONSTRAINT `fk_cita_mascota` FOREIGN KEY (`id_mascota`) REFERENCES `mascota` (`id_mascota`) ON DELETE RESTRICT,
  CONSTRAINT `fk_cita_veterinario` FOREIGN KEY (`id_veterinario`) REFERENCES `veterinario` (`id_veterinario`) ON DELETE RESTRICT,
  CONSTRAINT `fk_cita_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicio` (`id_servicio`) ON DELETE RESTRICT,
  CONSTRAINT `fk_cita_sede` FOREIGN KEY (`id_sede`) REFERENCES `sede` (`id_sede`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 28. historia_clinica
CREATE TABLE `historia_clinica` (
  `id_historia` integer PRIMARY KEY AUTO_INCREMENT,
  `id_mascota` integer NOT NULL,
  `id_cita` integer UNIQUE COMMENT 'Cita asociada, opcional y exclusiva de este registro clinico',
  `id_veterinario` integer NOT NULL,
  `fecha_atencion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `motivo_consulta` text NOT NULL,
  `diagnostico` text,
  `tratamiento_indicado` text,
  `peso_registrado` decimal(6,2),
  `temperatura` decimal(4,1),
  `proxima_revision` date,
  CONSTRAINT `ck_historia_peso` CHECK (peso_registrado IS NULL OR peso_registrado > 0),
  UNIQUE KEY `uq_historia_id_mascota` (`id_historia`, `id_mascota`),
  KEY `idx_historia_clinica_id_mascota_fecha_atencion` (`id_mascota`, `fecha_atencion`),
  KEY `idx_historia_clinica_id_veterinario` (`id_veterinario`),
  CONSTRAINT `fk_historia_mascota` FOREIGN KEY (`id_mascota`) REFERENCES `mascota` (`id_mascota`) ON DELETE RESTRICT,
  CONSTRAINT `fk_historia_veterinario` FOREIGN KEY (`id_veterinario`) REFERENCES `veterinario` (`id_veterinario`) ON DELETE RESTRICT,
  CONSTRAINT `fk_historia_cita` FOREIGN KEY (`id_cita`, `id_mascota`) REFERENCES `cita` (`id_cita`, `id_mascota`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='Registro de una atencion. Una mascota puede tener multiples registros a lo largo del tiempo';

-- 29. antecedente_medico
CREATE TABLE `antecedente_medico` (
  `id_antecedente` integer PRIMARY KEY AUTO_INCREMENT,
  `id_mascota` integer NOT NULL,
  `tipo` ENUM ('alergia', 'enfermedad_cronica', 'cirugia_previa', 'otro') NOT NULL,
  `descripcion` text NOT NULL,
  `severidad` ENUM ('leve', 'moderada', 'grave'),
  `fecha_diagnostico` date,
  `activo` boolean NOT NULL DEFAULT true,
  CONSTRAINT `ck_antecedente_medico_activo` CHECK (`activo` IN (0, 1)),
  KEY `idx_antecedente_medico_id_mascota` (`id_mascota`),
  CONSTRAINT `fk_antecedente_mascota` FOREIGN KEY (`id_mascota`) REFERENCES `mascota` (`id_mascota`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 30. jaula
CREATE TABLE `jaula` (
  `id_jaula` integer PRIMARY KEY AUTO_INCREMENT,
  `id_sede` integer NOT NULL,
  `numero_jaula` varchar(20) NOT NULL,
  `descripcion` varchar(120),
  `activa` boolean NOT NULL DEFAULT true,
  CONSTRAINT `ck_jaula_activa` CHECK (`activa` IN (0, 1)),
  UNIQUE KEY `uq_jaula_sede_numero` (`id_sede`, `numero_jaula`),
  CONSTRAINT `fk_jaula_sede` FOREIGN KEY (`id_sede`) REFERENCES `sede` (`id_sede`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 31. hospitalizacion
CREATE TABLE `hospitalizacion` (
  `id_hospitalizacion` integer PRIMARY KEY AUTO_INCREMENT,
  `id_mascota` integer NOT NULL,
  `id_historia` integer UNIQUE COMMENT 'Atencion asociada, opcional y exclusiva de esta estancia',
  `id_jaula` integer NOT NULL COMMENT 'La sede se obtiene vía jaula',
  `fecha_ingreso` timestamp NOT NULL,
  `fecha_salida_estimada` timestamp NULL DEFAULT NULL,
  `fecha_salida_real` timestamp NULL DEFAULT NULL COMMENT 'NULL = internado actualmente',
  `tipo_salida` ENUM ('alta', 'traslado', 'fallecimiento') COMMENT 'Forma de egreso. NULL mientras no exista fecha de salida real',
  `motivo` text NOT NULL,
  CONSTRAINT `ck_hosp_estimada` CHECK (fecha_salida_estimada IS NULL OR fecha_salida_estimada >= fecha_ingreso),
  CONSTRAINT `ck_hosp_real` CHECK (fecha_salida_real IS NULL OR fecha_salida_real >= fecha_ingreso),
  CONSTRAINT `ck_hosp_salida` CHECK ((fecha_salida_real IS NULL) = (tipo_salida IS NULL)),
  KEY `idx_hospitalizacion_id_mascota` (`id_mascota`),
  KEY `idx_hospitalizacion_id_jaula_fecha_salida_real` (`id_jaula`, `fecha_salida_real`),
  CONSTRAINT `fk_hosp_mascota` FOREIGN KEY (`id_mascota`) REFERENCES `mascota` (`id_mascota`) ON DELETE RESTRICT,
  CONSTRAINT `fk_hosp_jaula` FOREIGN KEY (`id_jaula`) REFERENCES `jaula` (`id_jaula`) ON DELETE RESTRICT,
  CONSTRAINT `fk_hosp_historia` FOREIGN KEY (`id_historia`, `id_mascota`) REFERENCES `historia_clinica` (`id_historia`, `id_mascota`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 32. documento
CREATE TABLE `documento` (
  `id_documento` integer PRIMARY KEY AUTO_INCREMENT,
  `id_historia` integer NOT NULL,
  `id_veterinario` integer NOT NULL COMMENT 'Quien cargó el archivo',
  `tipo_archivo` ENUM ('imagen', 'resultado_lab', 'consentimiento', 'otro') NOT NULL,
  `nombre_archivo` varchar(255) NOT NULL,
  `url_archivo` varchar(500) UNIQUE NOT NULL,
  `fecha_carga` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_documento_id_historia` (`id_historia`),
  CONSTRAINT `fk_documento_historia` FOREIGN KEY (`id_historia`) REFERENCES `historia_clinica` (`id_historia`) ON DELETE RESTRICT,
  CONSTRAINT `fk_documento_veterinario` FOREIGN KEY (`id_veterinario`) REFERENCES `veterinario` (`id_veterinario`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 33. proveedor
CREATE TABLE `proveedor` (
  `id_proveedor` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(150) NOT NULL,
  `nit` varchar(20) UNIQUE NOT NULL,
  `direccion` varchar(200),
  `activo` boolean NOT NULL DEFAULT true,
  CONSTRAINT `ck_proveedor_activo` CHECK (`activo` IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 34. proveedor_telefono
CREATE TABLE `proveedor_telefono` (
  `id_proveedor` integer NOT NULL,
  `telefono` varchar(20) NOT NULL,
  `tipo` ENUM ('movil', 'fijo') NOT NULL DEFAULT 'fijo',
  `es_principal` boolean NOT NULL DEFAULT false,
  PRIMARY KEY (`id_proveedor`, `telefono`),
  CONSTRAINT `ck_proveedor_telefono_es_principal` CHECK (`es_principal` IN (0, 1)),
  CONSTRAINT `fk_proveedor_telefono` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 35. proveedor_email
CREATE TABLE `proveedor_email` (
  `id_proveedor` integer NOT NULL,
  `email` varchar(120) NOT NULL,
  `es_principal` boolean NOT NULL DEFAULT false,
  PRIMARY KEY (`id_proveedor`, `email`),
  CONSTRAINT `ck_proveedor_email_es_principal` CHECK (`es_principal` IN (0, 1)),
  CONSTRAINT `fk_proveedor_email` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 36. medicamento
CREATE TABLE `medicamento` (
  `id_medicamento` integer PRIMARY KEY AUTO_INCREMENT,
  `id_laboratorio` integer NOT NULL,
  `id_presentacion` integer NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `activo` boolean NOT NULL DEFAULT true,
  CONSTRAINT `ck_medicamento_activo` CHECK (`activo` IN (0, 1)),
  UNIQUE KEY `uq_medicamento_producto` (`nombre`, `id_laboratorio`, `id_presentacion`),
  CONSTRAINT `fk_medicamento_laboratorio` FOREIGN KEY (`id_laboratorio`) REFERENCES `laboratorio` (`id_laboratorio`) ON DELETE RESTRICT,
  CONSTRAINT `fk_medicamento_presentacion` FOREIGN KEY (`id_presentacion`) REFERENCES `presentacion` (`id_presentacion`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='Catalogo de productos compartido por todas las sedes';

-- 37. medicamento_principio_activo
CREATE TABLE `medicamento_principio_activo` (
  `id_medicamento` integer NOT NULL,
  `id_principio_activo` integer NOT NULL,
  PRIMARY KEY (`id_medicamento`, `id_principio_activo`),
  CONSTRAINT `fk_medpa_medicamento` FOREIGN KEY (`id_medicamento`) REFERENCES `medicamento` (`id_medicamento`) ON DELETE CASCADE,
  CONSTRAINT `fk_medpa_principio` FOREIGN KEY (`id_principio_activo`) REFERENCES `principio_activo` (`id_principio_activo`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 38. medicamento_sede
CREATE TABLE `medicamento_sede` (
  `id_medicamento_sede` integer PRIMARY KEY AUTO_INCREMENT,
  `id_medicamento` integer NOT NULL,
  `id_sede` integer NOT NULL,
  `stock_minimo` integer NOT NULL DEFAULT 0 COMMENT 'Umbral de reposicion comparado con el stock vigente en v_stock_medicamento_sede',
  `precio_unitario` decimal(12,2) NOT NULL,
  `activo` boolean NOT NULL DEFAULT true,
  CONSTRAINT `ck_medsede_stock_min` CHECK (stock_minimo >= 0),
  CONSTRAINT `ck_medsede_precio` CHECK (precio_unitario >= 0),
  CONSTRAINT `ck_medicamento_sede_activo` CHECK (`activo` IN (0, 1)),
  UNIQUE KEY `uq_medicamento_sede` (`id_medicamento`, `id_sede`),
  CONSTRAINT `fk_medsede_medicamento` FOREIGN KEY (`id_medicamento`) REFERENCES `medicamento` (`id_medicamento`) ON DELETE RESTRICT,
  CONSTRAINT `fk_medsede_sede` FOREIGN KEY (`id_sede`) REFERENCES `sede` (`id_sede`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 39. lote_medicamento
CREATE TABLE `lote_medicamento` (
  `id_lote` integer PRIMARY KEY AUTO_INCREMENT,
  `id_medicamento_sede` integer NOT NULL,
  `id_proveedor` integer NOT NULL,
  `numero_lote` varchar(50) NOT NULL,
  `fecha_vencimiento` date NOT NULL,
  `cantidad_disponible` integer NOT NULL DEFAULT 0,
  `fecha_ingreso` date NOT NULL DEFAULT (CURRENT_DATE),
  CONSTRAINT `ck_lote_cantidad` CHECK (cantidad_disponible >= 0),
  CONSTRAINT `ck_lote_fechas` CHECK (fecha_vencimiento >= fecha_ingreso),
  UNIQUE KEY `uq_lote_medicamento_numero` (`id_medicamento_sede`, `numero_lote`),
  KEY `idx_lote_medicamento_fecha_vencimiento` (`fecha_vencimiento`),
  KEY `idx_lote_medicamento_id_proveedor` (`id_proveedor`),
  CONSTRAINT `fk_lote_medsede` FOREIGN KEY (`id_medicamento_sede`) REFERENCES `medicamento_sede` (`id_medicamento_sede`) ON DELETE RESTRICT,
  CONSTRAINT `fk_lote_proveedor` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 40. vacunacion
CREATE TABLE `vacunacion` (
  `id_vacunacion` integer PRIMARY KEY AUTO_INCREMENT,
  `id_mascota` integer NOT NULL,
  `id_servicio` integer NOT NULL COMMENT 'Vacuna o servicio periódico',
  `id_veterinario` integer NOT NULL COMMENT 'Quien aplicó',
  `id_lote` integer NOT NULL COMMENT 'Lote de la vacuna aplicada',
  `fecha_aplicacion` date NOT NULL,
  UNIQUE KEY `uq_vacunacion_mascota_servicio` (`id_vacunacion`, `id_mascota`, `id_servicio`),
  KEY `idx_vacunacion_id_mascota_fecha_aplicacion` (`id_mascota`, `fecha_aplicacion`),
  CONSTRAINT `fk_vacunacion_mascota` FOREIGN KEY (`id_mascota`) REFERENCES `mascota` (`id_mascota`) ON DELETE RESTRICT,
  CONSTRAINT `fk_vacunacion_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicio` (`id_servicio`) ON DELETE RESTRICT,
  CONSTRAINT `fk_vacunacion_veterinario` FOREIGN KEY (`id_veterinario`) REFERENCES `veterinario` (`id_veterinario`) ON DELETE RESTRICT,
  CONSTRAINT `fk_vacunacion_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote_medicamento` (`id_lote`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='Aplicacion realizada a una mascota con profesional y lote identificados';

-- 41. recordatorio_vacunacion
CREATE TABLE `recordatorio_vacunacion` (
  `id_recordatorio` integer PRIMARY KEY AUTO_INCREMENT,
  `id_mascota` integer NOT NULL,
  `id_servicio` integer NOT NULL,
  `fecha_proxima` date NOT NULL,
  `notificacion_enviada` boolean NOT NULL DEFAULT false,
  `id_vacunacion_cumplida` integer UNIQUE COMMENT 'Aplicacion que cumple el recordatorio. NULL indica que aun no se cumple',
  CONSTRAINT `ck_recordatorio_vacunacion_notificacion_enviada` CHECK (`notificacion_enviada` IN (0, 1)),
  KEY `idx_recordatorio_vacunacion_id_mascota_fecha_proxima` (`id_mascota`, `fecha_proxima`),
  KEY `idx_recordatorio_vacunacion_fecha_proxima` (`fecha_proxima`),
  CONSTRAINT `fk_recordatorio_mascota` FOREIGN KEY (`id_mascota`) REFERENCES `mascota` (`id_mascota`) ON DELETE RESTRICT,
  CONSTRAINT `fk_recordatorio_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicio` (`id_servicio`) ON DELETE RESTRICT,
  CONSTRAINT `fk_recordatorio_vacunacion` FOREIGN KEY (`id_vacunacion_cumplida`, `id_mascota`, `id_servicio`) REFERENCES `vacunacion` (`id_vacunacion`, `id_mascota`, `id_servicio`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 42. tratamiento_medicamento
CREATE TABLE `tratamiento_medicamento` (
  `id_tratamiento_medicamento` integer PRIMARY KEY AUTO_INCREMENT,
  `id_historia` integer NOT NULL,
  `id_lote` integer NOT NULL,
  `cantidad_utilizada` integer NOT NULL,
  `dosis_cantidad` decimal(10,3) NOT NULL COMMENT 'Cantidad numerica de la dosis, expresada en id_unidad_dosis',
  `id_unidad_dosis` integer NOT NULL COMMENT 'Unidad de la dosis',
  `frecuencia_horas` smallint COMMENT 'Intervalo entre dosis, expresado en horas',
  `duracion_dias` smallint,
  CONSTRAINT `ck_trat_cantidad` CHECK (cantidad_utilizada > 0),
  CONSTRAINT `ck_trat_dosis` CHECK (dosis_cantidad > 0),
  CONSTRAINT `ck_trat_frecuencia` CHECK (frecuencia_horas IS NULL OR frecuencia_horas > 0),
  CONSTRAINT `ck_trat_duracion` CHECK (duracion_dias IS NULL OR duracion_dias > 0),
  KEY `idx_tratamiento_medicamento_id_historia` (`id_historia`),
  KEY `idx_tratamiento_medicamento_id_lote` (`id_lote`),
  CONSTRAINT `fk_tratamiento_historia` FOREIGN KEY (`id_historia`) REFERENCES `historia_clinica` (`id_historia`) ON DELETE RESTRICT,
  CONSTRAINT `fk_tratamiento_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote_medicamento` (`id_lote`) ON DELETE RESTRICT,
  CONSTRAINT `fk_tratamiento_unidad` FOREIGN KEY (`id_unidad_dosis`) REFERENCES `unidad_medida` (`id_unidad`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 43. factura
CREATE TABLE `factura` (
  `id_factura` integer PRIMARY KEY AUTO_INCREMENT,
  `id_propietario` integer NOT NULL,
  `id_sede` integer NOT NULL,
  `fecha_emision` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `subtotal` decimal(12,2) NOT NULL,
  `impuestos` decimal(12,2) NOT NULL DEFAULT 0,
  `total` decimal(12,2) NOT NULL,
  `estado_pago` ENUM ('pendiente', 'pagada', 'anulada') NOT NULL DEFAULT 'pendiente',
  CONSTRAINT `ck_factura_total` CHECK (total = subtotal + impuestos),
  CONSTRAINT `ck_factura_montos` CHECK (subtotal >= 0 AND impuestos >= 0),
  KEY `idx_factura_id_propietario_fecha_emision` (`id_propietario`, `fecha_emision`),
  KEY `idx_factura_id_sede_fecha_emision` (`id_sede`, `fecha_emision`),
  KEY `idx_factura_estado_pago` (`estado_pago`),
  CONSTRAINT `fk_factura_propietario` FOREIGN KEY (`id_propietario`) REFERENCES `propietario` (`id_propietario`) ON DELETE RESTRICT,
  CONSTRAINT `fk_factura_sede` FOREIGN KEY (`id_sede`) REFERENCES `sede` (`id_sede`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='Importes almacenados del comprobante. La aplicacion controla emision, conciliacion e inmutabilidad';

-- 44. detalle_factura
CREATE TABLE `detalle_factura` (
  `id_detalle` integer PRIMARY KEY AUTO_INCREMENT,
  `id_factura` integer NOT NULL,
  `tipo_item` ENUM ('servicio', 'medicamento') NOT NULL COMMENT 'Discriminador del subtipo',
  `cantidad` integer NOT NULL DEFAULT 1,
  `precio_unitario` decimal(12,2) NOT NULL COMMENT 'Precio historico de la linea. Su subtotal se consulta en v_detalle_factura_subtotal',
  CONSTRAINT `ck_detalle_cantidad` CHECK (cantidad > 0),
  CONSTRAINT `ck_detalle_precio` CHECK (precio_unitario >= 0),
  UNIQUE KEY `uq_detalle_tipo` (`id_detalle`, `tipo_item`),
  KEY `idx_detalle_factura_id_factura` (`id_factura`),
  CONSTRAINT `fk_detalle_factura` FOREIGN KEY (`id_factura`) REFERENCES `factura` (`id_factura`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='Linea facturable. La aplicacion crea el detalle y su unico subtipo en la misma transaccion';

-- 45. detalle_factura_servicio
CREATE TABLE `detalle_factura_servicio` (
  `id_detalle` integer PRIMARY KEY,
  `tipo_item` ENUM ('servicio', 'medicamento') NOT NULL DEFAULT 'servicio',
  `id_servicio` integer NOT NULL,
  CONSTRAINT `ck_detsrv_tipo` CHECK (tipo_item = 'servicio'),
  KEY `idx_detalle_factura_servicio_id_servicio` (`id_servicio`),
  CONSTRAINT `fk_detsrv_detalle` FOREIGN KEY (`id_detalle`, `tipo_item`) REFERENCES `detalle_factura` (`id_detalle`, `tipo_item`) ON DELETE RESTRICT,
  CONSTRAINT `fk_detsrv_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicio` (`id_servicio`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 46. detalle_factura_medicamento
CREATE TABLE `detalle_factura_medicamento` (
  `id_detalle` integer PRIMARY KEY,
  `tipo_item` ENUM ('servicio', 'medicamento') NOT NULL DEFAULT 'medicamento',
  `id_medicamento` integer NOT NULL,
  CONSTRAINT `ck_detmed_tipo` CHECK (tipo_item = 'medicamento'),
  KEY `idx_detalle_factura_medicamento_id_medicamento` (`id_medicamento`),
  CONSTRAINT `fk_detmed_detalle` FOREIGN KEY (`id_detalle`, `tipo_item`) REFERENCES `detalle_factura` (`id_detalle`, `tipo_item`) ON DELETE RESTRICT,
  CONSTRAINT `fk_detmed_medicamento` FOREIGN KEY (`id_medicamento`) REFERENCES `medicamento` (`id_medicamento`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- 47. pago
CREATE TABLE `pago` (
  `id_pago` integer PRIMARY KEY AUTO_INCREMENT,
  `id_factura` integer NOT NULL,
  `id_medio_pago` smallint NOT NULL,
  `fecha_pago` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `monto` decimal(12,2) NOT NULL,
  `referencia` varchar(100),
  CONSTRAINT `ck_pago_monto` CHECK (monto > 0),
  KEY `idx_pago_id_factura` (`id_factura`),
  CONSTRAINT `fk_pago_factura` FOREIGN KEY (`id_factura`) REFERENCES `factura` (`id_factura`) ON DELETE RESTRICT,
  CONSTRAINT `fk_pago_medio` FOREIGN KEY (`id_medio_pago`) REFERENCES `medio_pago` (`id_medio_pago`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

-- VISTAS DE CONSULTA
-- 1. Ultimo peso no nulo. El identificador resuelve empates de fecha.
CREATE SQL SECURITY INVOKER VIEW v_peso_actual_mascota AS
SELECT m.id_mascota, m.nombre, h.id_historia, h.fecha_atencion,
       h.peso_registrado AS peso_actual
FROM mascota AS m
LEFT JOIN (
  SELECT id_historia, id_mascota, fecha_atencion, peso_registrado,
         ROW_NUMBER() OVER (
           PARTITION BY id_mascota ORDER BY fecha_atencion DESC, id_historia DESC
         ) AS posicion
  FROM historia_clinica
  WHERE peso_registrado IS NOT NULL
) AS h ON h.id_mascota = m.id_mascota AND h.posicion = 1;

-- 2. El vencimiento se evalua con la fecha de la conexion que consulta.
CREATE SQL SECURITY INVOKER VIEW v_estado_recordatorio AS
SELECT r.id_recordatorio, r.id_mascota, r.id_servicio, r.fecha_proxima,
       r.notificacion_enviada, r.id_vacunacion_cumplida,
       CASE
         WHEN r.id_vacunacion_cumplida IS NOT NULL THEN 'cumplido'
         WHEN r.fecha_proxima < CURRENT_DATE THEN 'vencido'
         ELSE 'pendiente'
       END AS estado
FROM recordatorio_vacunacion AS r;

-- 3. Stock fisico: todos los lotes. Stock actual: lotes no vencidos.
-- Un lote que vence hoy se considera vigente durante el dia actual.
CREATE SQL SECURITY INVOKER VIEW v_stock_medicamento_sede AS
SELECT ms.id_medicamento_sede, ms.id_medicamento, ms.id_sede,
       ms.stock_minimo, ms.precio_unitario, ms.activo,
       COALESCE(s.stock_fisico, 0) AS stock_fisico,
       COALESCE(s.stock_actual, 0) AS stock_actual,
       COALESCE(s.stock_vencido, 0) AS stock_vencido,
       (COALESCE(s.stock_actual, 0) < ms.stock_minimo) AS bajo_minimo
FROM medicamento_sede AS ms
LEFT JOIN (
  SELECT id_medicamento_sede,
         SUM(cantidad_disponible) AS stock_fisico,
         SUM(CASE WHEN fecha_vencimiento >= CURRENT_DATE
                  THEN cantidad_disponible ELSE 0 END) AS stock_actual,
         SUM(CASE WHEN fecha_vencimiento < CURRENT_DATE
                  THEN cantidad_disponible ELSE 0 END) AS stock_vencido
  FROM lote_medicamento
  GROUP BY id_medicamento_sede
) AS s ON s.id_medicamento_sede = ms.id_medicamento_sede;

-- 4. Subtotal calculado con el precio guardado en cada linea.
-- detalle_completo indica si existe el subtipo correspondiente.
CREATE SQL SECURITY INVOKER VIEW v_detalle_factura_subtotal AS
SELECT d.id_detalle, d.id_factura, d.tipo_item, d.cantidad,
       d.precio_unitario, d.cantidad * d.precio_unitario AS subtotal_linea,
       ds.id_servicio, dm.id_medicamento,
       CASE WHEN d.tipo_item = 'servicio' THEN s.nombre ELSE m.nombre END AS nombre_item,
       (ds.id_detalle IS NOT NULL OR dm.id_detalle IS NOT NULL) AS detalle_completo
FROM detalle_factura AS d
LEFT JOIN detalle_factura_servicio AS ds ON ds.id_detalle = d.id_detalle
LEFT JOIN servicio AS s ON s.id_servicio = ds.id_servicio
LEFT JOIN detalle_factura_medicamento AS dm ON dm.id_detalle = d.id_detalle
LEFT JOIN medicamento AS m ON m.id_medicamento = dm.id_medicamento;

-- 5. Estado de la estancia a partir de su egreso.
CREATE SQL SECURITY INVOKER VIEW v_hospitalizacion_estado AS
SELECT h.id_hospitalizacion, h.id_mascota, h.id_historia, h.id_jaula,
       h.fecha_ingreso, h.fecha_salida_estimada, h.fecha_salida_real,
       h.tipo_salida, h.motivo,
       CASE WHEN h.fecha_salida_real IS NULL THEN 'internado'
            ELSE h.tipo_salida END AS estado
FROM hospitalizacion AS h;
