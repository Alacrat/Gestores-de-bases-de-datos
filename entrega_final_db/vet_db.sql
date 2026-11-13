CREATE TABLE `departamento` (
  `id_departamento` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(80) UNIQUE NOT NULL
);

CREATE TABLE `ciudad` (
  `id_ciudad` integer PRIMARY KEY AUTO_INCREMENT,
  `id_departamento` integer NOT NULL,
  `nombre` varchar(80) NOT NULL
);

CREATE TABLE `tipo_documento_identidad` (
  `id_tipo_documento` smallint PRIMARY KEY AUTO_INCREMENT,
  `codigo` varchar(10) UNIQUE NOT NULL COMMENT 'CC, CE, TI, PAS, NIT...',
  `nombre` varchar(60) NOT NULL
);

CREATE TABLE `rol` (
  `id_rol` smallint PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(40) UNIQUE NOT NULL COMMENT 'administrador, veterinario, auxiliar, recepcion...'
);

CREATE TABLE `especie` (
  `id_especie` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(60) UNIQUE NOT NULL COMMENT 'Canino, felino, ave...'
);

CREATE TABLE `raza` (
  `id_raza` integer PRIMARY KEY AUTO_INCREMENT,
  `id_especie` integer NOT NULL,
  `nombre` varchar(80) NOT NULL COMMENT 'Cada especie incluye una raza "Sin raza definida"'
);

CREATE TABLE `especialidad` (
  `id_especialidad` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(80) UNIQUE NOT NULL
);

CREATE TABLE `categoria_servicio` (
  `id_categoria` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(60) UNIQUE NOT NULL COMMENT 'Consulta, Vacuna, Cirugía, Laboratorio, Imagen, Peluquería, Hospitalización, Hotel'
);

CREATE TABLE `laboratorio` (
  `id_laboratorio` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(120) UNIQUE NOT NULL
);

CREATE TABLE `presentacion` (
  `id_presentacion` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(60) UNIQUE NOT NULL COMMENT 'Tableta, ampolla, jarabe...'
);

CREATE TABLE `principio_activo` (
  `id_principio_activo` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(120) UNIQUE NOT NULL
);

CREATE TABLE `unidad_medida` (
  `id_unidad` integer PRIMARY KEY AUTO_INCREMENT,
  `simbolo` varchar(15) UNIQUE NOT NULL COMMENT 'mg, ml, UI, tableta, gota...',
  `nombre` varchar(60) NOT NULL
);

CREATE TABLE `medio_pago` (
  `id_medio_pago` smallint PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(60) UNIQUE NOT NULL COMMENT 'Efectivo, tarjeta, transferencia...',
  `activo` boolean NOT NULL DEFAULT true
);

CREATE TABLE `sede` (
  `id_sede` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(120) UNIQUE NOT NULL,
  `direccion` varchar(200) NOT NULL,
  `id_ciudad` integer NOT NULL,
  `fecha_apertura` date
);

CREATE TABLE `sede_telefono` (
  `id_sede` integer NOT NULL,
  `telefono` varchar(20) NOT NULL,
  `tipo` ENUM ('movil', 'fijo') NOT NULL DEFAULT 'fijo',
  `es_principal` boolean NOT NULL DEFAULT false,
  PRIMARY KEY (`id_sede`, `telefono`)
);

CREATE TABLE `sede_email` (
  `id_sede` integer NOT NULL,
  `email` varchar(120) NOT NULL,
  `es_principal` boolean NOT NULL DEFAULT false,
  PRIMARY KEY (`id_sede`, `email`)
);

CREATE TABLE `persona` (
  `id_persona` integer PRIMARY KEY AUTO_INCREMENT,
  `id_tipo_documento` smallint NOT NULL,
  `numero_documento` varchar(30) NOT NULL,
  `nombre` varchar(80) NOT NULL,
  `apellido` varchar(80) NOT NULL,
  `direccion` varchar(200)
);

CREATE TABLE `persona_telefono` (
  `id_persona` integer NOT NULL,
  `telefono` varchar(20) NOT NULL,
  `tipo` ENUM ('movil', 'fijo') NOT NULL DEFAULT 'movil',
  `es_principal` boolean NOT NULL DEFAULT false,
  PRIMARY KEY (`id_persona`, `telefono`)
);

CREATE TABLE `persona_email` (
  `id_persona` integer NOT NULL,
  `email` varchar(120) NOT NULL,
  `es_principal` boolean NOT NULL DEFAULT false,
  PRIMARY KEY (`id_persona`, `email`)
);

CREATE TABLE `propietario` (
  `id_propietario` integer PRIMARY KEY AUTO_INCREMENT,
  `id_persona` integer UNIQUE NOT NULL,
  `fecha_registro` date NOT NULL DEFAULT (current_date)
);

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
  CONSTRAINT `ck_mascota_fechas` CHECK (fecha_fallecimiento IS NULL OR fecha_nacimiento IS NULL OR fecha_fallecimiento >= fecha_nacimiento)
);

CREATE TABLE `veterinario` (
  `id_veterinario` integer PRIMARY KEY AUTO_INCREMENT,
  `id_persona` integer UNIQUE NOT NULL,
  `id_sede` integer NOT NULL,
  `id_rol` smallint NOT NULL COMMENT 'Función laboral: veterinario, auxiliar, recepción',
  `numero_licencia` varchar(40) UNIQUE COMMENT 'Registro profesional (si aplica)',
  `fecha_ingreso` date NOT NULL,
  `activo` boolean NOT NULL DEFAULT true COMMENT 'Baja lógica: conserva el historial'
);

CREATE TABLE `veterinario_especialidad` (
  `id_veterinario` integer NOT NULL,
  `id_especialidad` integer NOT NULL,
  PRIMARY KEY (`id_veterinario`, `id_especialidad`)
);

CREATE TABLE `usuario` (
  `id_usuario` integer PRIMARY KEY AUTO_INCREMENT,
  `id_veterinario` integer UNIQUE COMMENT 'NULL para cuentas puramente técnicas',
  `id_rol` smallint NOT NULL COMMENT 'Rol de permisos en el sistema',
  `nombre_usuario` varchar(50) UNIQUE NOT NULL,
  `contrasena_hash` varchar(255) NOT NULL,
  `activo` boolean NOT NULL DEFAULT true,
  `ultimo_acceso` timestamp,
  `fecha_creacion` timestamp NOT NULL DEFAULT (now())
);

CREATE TABLE `horario_veterinario` (
  `id_horario` integer PRIMARY KEY AUTO_INCREMENT,
  `id_veterinario` integer NOT NULL,
  `dia_semana` smallint NOT NULL COMMENT '1 = Lunes ... 7 = Domingo',
  `hora_inicio` time NOT NULL,
  `hora_fin` time NOT NULL,
  CONSTRAINT `ck_horario_dia` CHECK (dia_semana BETWEEN 1 AND 7),
  CONSTRAINT `ck_horario_rango` CHECK (hora_fin > hora_inicio)
);

CREATE TABLE `servicio` (
  `id_servicio` integer PRIMARY KEY AUTO_INCREMENT,
  `id_categoria` integer NOT NULL,
  `nombre` varchar(120) UNIQUE NOT NULL,
  `descripcion` text,
  `precio_base` decimal(12,2) NOT NULL DEFAULT 0,
  `duracion_estimada_min` smallint,
  `periodicidad_dias` smallint COMMENT 'NULL = no genera recordatorios. Reemplaza al booleano requiere_periodicidad',
  `activo` boolean NOT NULL DEFAULT true,
  CONSTRAINT `ck_servicio_precio` CHECK (precio_base >= 0),
  CONSTRAINT `ck_servicio_periodicidad` CHECK (periodicidad_dias IS NULL OR periodicidad_dias > 0)
);

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
  `fecha_creacion` timestamp NOT NULL DEFAULT (now()),
  CONSTRAINT `ck_cita_videollamada` CHECK ((canal = 'telemedicina') = (url_videollamada IS NOT NULL))
);

CREATE TABLE `historia_clinica` (
  `id_historia` integer PRIMARY KEY AUTO_INCREMENT,
  `id_mascota` integer NOT NULL,
  `id_cita` integer UNIQUE COMMENT 'Relación 1:0..1 con cita',
  `id_veterinario` integer NOT NULL,
  `fecha_atencion` timestamp NOT NULL DEFAULT (now()),
  `motivo_consulta` text NOT NULL,
  `diagnostico` text,
  `tratamiento_indicado` text,
  `peso_registrado` decimal(6,2),
  `temperatura` decimal(4,1),
  `proxima_revision` date,
  CONSTRAINT `ck_historia_peso` CHECK (peso_registrado IS NULL OR peso_registrado > 0)
);

CREATE TABLE `antecedente_medico` (
  `id_antecedente` integer PRIMARY KEY AUTO_INCREMENT,
  `id_mascota` integer NOT NULL,
  `tipo` ENUM ('alergia', 'enfermedad_cronica', 'cirugia_previa', 'otro') NOT NULL,
  `descripcion` text NOT NULL,
  `severidad` ENUM ('leve', 'moderada', 'grave'),
  `fecha_diagnostico` date,
  `activo` boolean NOT NULL DEFAULT true
);

CREATE TABLE `jaula` (
  `id_jaula` integer PRIMARY KEY AUTO_INCREMENT,
  `id_sede` integer NOT NULL,
  `numero_jaula` varchar(20) NOT NULL,
  `descripcion` varchar(120),
  `activa` boolean NOT NULL DEFAULT true
);

CREATE TABLE `hospitalizacion` (
  `id_hospitalizacion` integer PRIMARY KEY AUTO_INCREMENT,
  `id_mascota` integer NOT NULL,
  `id_historia` integer UNIQUE COMMENT 'Relación 1:0..1 con historia_clinica',
  `id_jaula` integer NOT NULL COMMENT 'La sede se obtiene vía jaula',
  `fecha_ingreso` timestamp NOT NULL,
  `fecha_salida_estimada` timestamp,
  `fecha_salida_real` timestamp COMMENT 'NULL = internado actualmente',
  `tipo_salida` ENUM ('alta', 'traslado', 'fallecimiento') COMMENT 'NULL mientras esté internado. Reemplaza al atributo derivado estado',
  `motivo` text NOT NULL,
  CONSTRAINT `ck_hosp_estimada` CHECK (fecha_salida_estimada IS NULL OR fecha_salida_estimada >= fecha_ingreso),
  CONSTRAINT `ck_hosp_real` CHECK (fecha_salida_real IS NULL OR fecha_salida_real >= fecha_ingreso),
  CONSTRAINT `ck_hosp_salida` CHECK ((fecha_salida_real IS NULL) = (tipo_salida IS NULL))
);

CREATE TABLE `documento` (
  `id_documento` integer PRIMARY KEY AUTO_INCREMENT,
  `id_historia` integer NOT NULL,
  `id_veterinario` integer NOT NULL COMMENT 'Quien cargó el archivo',
  `tipo_archivo` ENUM ('imagen', 'resultado_lab', 'consentimiento', 'otro') NOT NULL,
  `nombre_archivo` varchar(255) NOT NULL,
  `url_archivo` varchar(500) UNIQUE NOT NULL,
  `fecha_carga` timestamp NOT NULL DEFAULT (now())
);

CREATE TABLE `vacunacion` (
  `id_vacunacion` integer PRIMARY KEY AUTO_INCREMENT,
  `id_mascota` integer NOT NULL,
  `id_servicio` integer NOT NULL COMMENT 'Vacuna o servicio periódico',
  `id_veterinario` integer NOT NULL COMMENT 'Quien aplicó',
  `id_lote` integer NOT NULL COMMENT 'Lote de la vacuna aplicada',
  `fecha_aplicacion` date NOT NULL
);

CREATE TABLE `recordatorio_vacunacion` (
  `id_recordatorio` integer PRIMARY KEY AUTO_INCREMENT,
  `id_mascota` integer NOT NULL,
  `id_servicio` integer NOT NULL,
  `fecha_proxima` date NOT NULL,
  `notificacion_enviada` boolean NOT NULL DEFAULT false,
  `id_vacunacion_cumplida` integer UNIQUE COMMENT 'NULL = pendiente/vencido. Estado se deriva (vista v_estado_recordatorio)'
);

CREATE TABLE `proveedor` (
  `id_proveedor` integer PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(150) NOT NULL,
  `nit` varchar(20) UNIQUE NOT NULL,
  `direccion` varchar(200),
  `activo` boolean NOT NULL DEFAULT true
);

CREATE TABLE `proveedor_telefono` (
  `id_proveedor` integer NOT NULL,
  `telefono` varchar(20) NOT NULL,
  `tipo` ENUM ('movil', 'fijo') NOT NULL DEFAULT 'fijo',
  `es_principal` boolean NOT NULL DEFAULT false,
  PRIMARY KEY (`id_proveedor`, `telefono`)
);

CREATE TABLE `proveedor_email` (
  `id_proveedor` integer NOT NULL,
  `email` varchar(120) NOT NULL,
  `es_principal` boolean NOT NULL DEFAULT false,
  PRIMARY KEY (`id_proveedor`, `email`)
);

CREATE TABLE `medicamento` (
  `id_medicamento` integer PRIMARY KEY AUTO_INCREMENT,
  `id_laboratorio` integer NOT NULL,
  `id_presentacion` integer NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `activo` boolean NOT NULL DEFAULT true
);

CREATE TABLE `medicamento_principio_activo` (
  `id_medicamento` integer NOT NULL,
  `id_principio_activo` integer NOT NULL,
  PRIMARY KEY (`id_medicamento`, `id_principio_activo`)
);

CREATE TABLE `medicamento_sede` (
  `id_medicamento_sede` integer PRIMARY KEY AUTO_INCREMENT,
  `id_medicamento` integer NOT NULL,
  `id_sede` integer NOT NULL,
  `stock_minimo` integer NOT NULL DEFAULT 0 COMMENT 'Umbral de reposición. stock_actual = SUM(lote.cantidad_disponible) (vista)',
  `precio_unitario` decimal(12,2) NOT NULL,
  `activo` boolean NOT NULL DEFAULT true,
  CONSTRAINT `ck_medsede_stock_min` CHECK (stock_minimo >= 0),
  CONSTRAINT `ck_medsede_precio` CHECK (precio_unitario >= 0)
);

CREATE TABLE `lote_medicamento` (
  `id_lote` integer PRIMARY KEY AUTO_INCREMENT,
  `id_medicamento_sede` integer NOT NULL,
  `id_proveedor` integer NOT NULL,
  `numero_lote` varchar(50) NOT NULL,
  `fecha_vencimiento` date NOT NULL,
  `cantidad_disponible` integer NOT NULL DEFAULT 0,
  `fecha_ingreso` date NOT NULL DEFAULT (current_date),
  CONSTRAINT `ck_lote_cantidad` CHECK (cantidad_disponible >= 0),
  CONSTRAINT `ck_lote_fechas` CHECK (fecha_vencimiento >= fecha_ingreso)
);

CREATE TABLE `tratamiento_medicamento` (
  `id_tratamiento_medicamento` integer PRIMARY KEY AUTO_INCREMENT,
  `id_historia` integer NOT NULL,
  `id_lote` integer NOT NULL,
  `cantidad_utilizada` integer NOT NULL,
  `dosis_cantidad` decimal(10,3) NOT NULL COMMENT 'Valor numérico de la dosis (antes texto "5 mg")',
  `id_unidad_dosis` integer NOT NULL COMMENT 'Unidad de la dosis',
  `frecuencia_horas` smallint COMMENT 'Cada cuántas horas (antes texto libre)',
  `duracion_dias` smallint,
  CONSTRAINT `ck_trat_cantidad` CHECK (cantidad_utilizada > 0),
  CONSTRAINT `ck_trat_dosis` CHECK (dosis_cantidad > 0),
  CONSTRAINT `ck_trat_frecuencia` CHECK (frecuencia_horas IS NULL OR frecuencia_horas > 0),
  CONSTRAINT `ck_trat_duracion` CHECK (duracion_dias IS NULL OR duracion_dias > 0)
);

CREATE TABLE `factura` (
  `id_factura` integer PRIMARY KEY AUTO_INCREMENT,
  `id_propietario` integer NOT NULL,
  `id_sede` integer NOT NULL,
  `fecha_emision` timestamp NOT NULL DEFAULT (now()),
  `subtotal` decimal(12,2) NOT NULL,
  `impuestos` decimal(12,2) NOT NULL DEFAULT 0,
  `total` decimal(12,2) NOT NULL,
  `estado_pago` ENUM ('pendiente', 'pagada', 'anulada') NOT NULL DEFAULT 'pendiente',
  CONSTRAINT `ck_factura_total` CHECK (total = subtotal + impuestos),
  CONSTRAINT `ck_factura_montos` CHECK (subtotal >= 0 AND impuestos >= 0)
);

CREATE TABLE `detalle_factura` (
  `id_detalle` integer PRIMARY KEY AUTO_INCREMENT,
  `id_factura` integer NOT NULL,
  `tipo_item` ENUM ('servicio', 'medicamento') NOT NULL COMMENT 'Discriminador del subtipo',
  `cantidad` integer NOT NULL DEFAULT 1,
  `precio_unitario` decimal(12,2) NOT NULL COMMENT 'Precio congelado al facturar. Subtotal de línea = cantidad * precio_unitario (vista)',
  CONSTRAINT `ck_detalle_cantidad` CHECK (cantidad > 0),
  CONSTRAINT `ck_detalle_precio` CHECK (precio_unitario >= 0)
);

CREATE TABLE `detalle_factura_servicio` (
  `id_detalle` integer PRIMARY KEY,
  `tipo_item` ENUM ('servicio', 'medicamento') NOT NULL DEFAULT 'servicio',
  `id_servicio` integer NOT NULL,
  CONSTRAINT `ck_detsrv_tipo` CHECK (tipo_item = 'servicio')
);

CREATE TABLE `detalle_factura_medicamento` (
  `id_detalle` integer PRIMARY KEY,
  `tipo_item` ENUM ('servicio', 'medicamento') NOT NULL DEFAULT 'medicamento',
  `id_medicamento` integer NOT NULL,
  CONSTRAINT `ck_detmed_tipo` CHECK (tipo_item = 'medicamento')
);

CREATE TABLE `pago` (
  `id_pago` integer PRIMARY KEY AUTO_INCREMENT,
  `id_factura` integer NOT NULL,
  `id_medio_pago` smallint NOT NULL,
  `fecha_pago` timestamp NOT NULL DEFAULT (now()),
  `monto` decimal(12,2) NOT NULL,
  `referencia` varchar(100),
  CONSTRAINT `ck_pago_monto` CHECK (monto > 0)
);

CREATE UNIQUE INDEX `uq_ciudad_departamento_nombre` ON `ciudad` (`id_departamento`, `nombre`);

CREATE UNIQUE INDEX `uq_raza_especie_nombre` ON `raza` (`id_especie`, `nombre`);

CREATE UNIQUE INDEX `uq_persona_documento` ON `persona` (`id_tipo_documento`, `numero_documento`);

CREATE INDEX `mascota_index_3` ON `mascota` (`id_propietario`);

CREATE INDEX `mascota_index_4` ON `mascota` (`id_sede`);

CREATE INDEX `mascota_index_5` ON `mascota` (`id_raza`);

CREATE INDEX `veterinario_index_6` ON `veterinario` (`id_sede`);

CREATE INDEX `veterinario_index_7` ON `veterinario` (`id_rol`);

CREATE UNIQUE INDEX `uq_horario_bloque` ON `horario_veterinario` (`id_veterinario`, `dia_semana`, `hora_inicio`);

CREATE UNIQUE INDEX `uq_cita_id_mascota` ON `cita` (`id_cita`, `id_mascota`);

CREATE INDEX `cita_index_10` ON `cita` (`id_mascota`, `fecha_hora`);

CREATE INDEX `cita_index_11` ON `cita` (`id_veterinario`, `fecha_hora`);

CREATE INDEX `cita_index_12` ON `cita` (`id_sede`, `fecha_hora`);

CREATE UNIQUE INDEX `uq_historia_id_mascota` ON `historia_clinica` (`id_historia`, `id_mascota`);

CREATE INDEX `historia_clinica_index_14` ON `historia_clinica` (`id_mascota`, `fecha_atencion`);

CREATE INDEX `historia_clinica_index_15` ON `historia_clinica` (`id_veterinario`);

CREATE INDEX `antecedente_medico_index_16` ON `antecedente_medico` (`id_mascota`);

CREATE UNIQUE INDEX `uq_jaula_sede_numero` ON `jaula` (`id_sede`, `numero_jaula`);

CREATE INDEX `hospitalizacion_index_18` ON `hospitalizacion` (`id_mascota`);

CREATE INDEX `hospitalizacion_index_19` ON `hospitalizacion` (`id_jaula`, `fecha_salida_real`);

CREATE INDEX `documento_index_20` ON `documento` (`id_historia`);

CREATE UNIQUE INDEX `uq_vacunacion_mascota_servicio` ON `vacunacion` (`id_vacunacion`, `id_mascota`, `id_servicio`);

CREATE INDEX `vacunacion_index_22` ON `vacunacion` (`id_mascota`, `fecha_aplicacion`);

CREATE INDEX `recordatorio_vacunacion_index_23` ON `recordatorio_vacunacion` (`id_mascota`, `fecha_proxima`);

CREATE INDEX `recordatorio_vacunacion_index_24` ON `recordatorio_vacunacion` (`fecha_proxima`);

CREATE UNIQUE INDEX `uq_medicamento_producto` ON `medicamento` (`nombre`, `id_laboratorio`, `id_presentacion`);

CREATE UNIQUE INDEX `uq_medicamento_sede` ON `medicamento_sede` (`id_medicamento`, `id_sede`);

CREATE UNIQUE INDEX `uq_lote_medicamento_numero` ON `lote_medicamento` (`id_medicamento_sede`, `numero_lote`);

CREATE INDEX `lote_medicamento_index_28` ON `lote_medicamento` (`fecha_vencimiento`);

CREATE INDEX `lote_medicamento_index_29` ON `lote_medicamento` (`id_proveedor`);

CREATE INDEX `tratamiento_medicamento_index_30` ON `tratamiento_medicamento` (`id_historia`);

CREATE INDEX `tratamiento_medicamento_index_31` ON `tratamiento_medicamento` (`id_lote`);

CREATE INDEX `factura_index_32` ON `factura` (`id_propietario`, `fecha_emision`);

CREATE INDEX `factura_index_33` ON `factura` (`id_sede`, `fecha_emision`);

CREATE INDEX `factura_index_34` ON `factura` (`estado_pago`);

CREATE UNIQUE INDEX `uq_detalle_tipo` ON `detalle_factura` (`id_detalle`, `tipo_item`);

CREATE INDEX `detalle_factura_index_36` ON `detalle_factura` (`id_factura`);

CREATE INDEX `detalle_factura_servicio_index_37` ON `detalle_factura_servicio` (`id_servicio`);

CREATE INDEX `detalle_factura_medicamento_index_38` ON `detalle_factura_medicamento` (`id_medicamento`);

CREATE INDEX `pago_index_39` ON `pago` (`id_factura`);

ALTER TABLE `persona` COMMENT = 'Supertipo de propietario y veterinario: una misma persona puede cumplir ambos roles sin duplicar sus datos';

ALTER TABLE `mascota` COMMENT = 'peso_actual se elimina (dato derivado): ver vista v_peso_actual_mascota';

ALTER TABLE `vacunacion` COMMENT = 'Hecho ya ocurrido. Separado del recordatorio (evento futuro) para eliminar columnas nulas según estado';

ALTER TABLE `medicamento` COMMENT = 'Catálogo global. Los datos por sede pasan a medicamento_sede';

ALTER TABLE `factura` COMMENT = 'subtotal/impuestos/total se conservan como desnormalización controlada (comprobante fiscal inmutable)';

ALTER TABLE `detalle_factura` COMMENT = 'Supertipo de línea facturable. Cada línea tiene exactamente una fila en detalle_factura_servicio o detalle_factura_medicamento';

ALTER TABLE `ciudad` ADD CONSTRAINT `fk_ciudad_departamento` FOREIGN KEY (`id_departamento`) REFERENCES `departamento` (`id_departamento`) ON DELETE RESTRICT;

ALTER TABLE `raza` ADD CONSTRAINT `fk_raza_especie` FOREIGN KEY (`id_especie`) REFERENCES `especie` (`id_especie`) ON DELETE RESTRICT;

ALTER TABLE `sede` ADD CONSTRAINT `fk_sede_ciudad` FOREIGN KEY (`id_ciudad`) REFERENCES `ciudad` (`id_ciudad`) ON DELETE RESTRICT;

ALTER TABLE `sede_telefono` ADD CONSTRAINT `fk_sede_telefono` FOREIGN KEY (`id_sede`) REFERENCES `sede` (`id_sede`) ON DELETE CASCADE;

ALTER TABLE `sede_email` ADD CONSTRAINT `fk_sede_email` FOREIGN KEY (`id_sede`) REFERENCES `sede` (`id_sede`) ON DELETE CASCADE;

ALTER TABLE `persona` ADD CONSTRAINT `fk_persona_tipo_doc` FOREIGN KEY (`id_tipo_documento`) REFERENCES `tipo_documento_identidad` (`id_tipo_documento`) ON DELETE RESTRICT;

ALTER TABLE `persona_telefono` ADD CONSTRAINT `fk_persona_telefono` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE;

ALTER TABLE `persona_email` ADD CONSTRAINT `fk_persona_email` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE;

ALTER TABLE `persona` ADD CONSTRAINT `fk_propietario_persona` FOREIGN KEY (`id_persona`) REFERENCES `propietario` (`id_persona`) ON DELETE RESTRICT;

ALTER TABLE `persona` ADD CONSTRAINT `fk_veterinario_persona` FOREIGN KEY (`id_persona`) REFERENCES `veterinario` (`id_persona`) ON DELETE RESTRICT;

ALTER TABLE `mascota` ADD CONSTRAINT `fk_mascota_propietario` FOREIGN KEY (`id_propietario`) REFERENCES `propietario` (`id_propietario`) ON DELETE RESTRICT;

ALTER TABLE `mascota` ADD CONSTRAINT `fk_mascota_sede` FOREIGN KEY (`id_sede`) REFERENCES `sede` (`id_sede`) ON DELETE RESTRICT;

ALTER TABLE `mascota` ADD CONSTRAINT `fk_mascota_raza` FOREIGN KEY (`id_raza`) REFERENCES `raza` (`id_raza`) ON DELETE RESTRICT;

ALTER TABLE `veterinario` ADD CONSTRAINT `fk_veterinario_sede` FOREIGN KEY (`id_sede`) REFERENCES `sede` (`id_sede`) ON DELETE RESTRICT;

ALTER TABLE `veterinario` ADD CONSTRAINT `fk_veterinario_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE RESTRICT;

ALTER TABLE `veterinario_especialidad` ADD CONSTRAINT `fk_vetesp_veterinario` FOREIGN KEY (`id_veterinario`) REFERENCES `veterinario` (`id_veterinario`) ON DELETE CASCADE;

ALTER TABLE `veterinario_especialidad` ADD CONSTRAINT `fk_vetesp_especialidad` FOREIGN KEY (`id_especialidad`) REFERENCES `especialidad` (`id_especialidad`) ON DELETE RESTRICT;

ALTER TABLE `veterinario` ADD CONSTRAINT `fk_usuario_veterinario` FOREIGN KEY (`id_veterinario`) REFERENCES `usuario` (`id_veterinario`) ON DELETE RESTRICT;

ALTER TABLE `usuario` ADD CONSTRAINT `fk_usuario_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE RESTRICT;

ALTER TABLE `horario_veterinario` ADD CONSTRAINT `fk_horario_veterinario` FOREIGN KEY (`id_veterinario`) REFERENCES `veterinario` (`id_veterinario`) ON DELETE CASCADE;

ALTER TABLE `servicio` ADD CONSTRAINT `fk_servicio_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria_servicio` (`id_categoria`) ON DELETE RESTRICT;

ALTER TABLE `cita` ADD CONSTRAINT `fk_cita_mascota` FOREIGN KEY (`id_mascota`) REFERENCES `mascota` (`id_mascota`) ON DELETE RESTRICT;

ALTER TABLE `cita` ADD CONSTRAINT `fk_cita_veterinario` FOREIGN KEY (`id_veterinario`) REFERENCES `veterinario` (`id_veterinario`) ON DELETE RESTRICT;

ALTER TABLE `cita` ADD CONSTRAINT `fk_cita_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicio` (`id_servicio`) ON DELETE RESTRICT;

ALTER TABLE `cita` ADD CONSTRAINT `fk_cita_sede` FOREIGN KEY (`id_sede`) REFERENCES `sede` (`id_sede`) ON DELETE RESTRICT;

ALTER TABLE `historia_clinica` ADD CONSTRAINT `fk_historia_mascota` FOREIGN KEY (`id_mascota`) REFERENCES `mascota` (`id_mascota`) ON DELETE RESTRICT;

ALTER TABLE `historia_clinica` ADD CONSTRAINT `fk_historia_veterinario` FOREIGN KEY (`id_veterinario`) REFERENCES `veterinario` (`id_veterinario`) ON DELETE RESTRICT;

ALTER TABLE `historia_clinica` ADD CONSTRAINT `fk_historia_cita` FOREIGN KEY (`id_cita`, `id_mascota`) REFERENCES `cita` (`id_cita`, `id_mascota`) ON DELETE RESTRICT;

ALTER TABLE `antecedente_medico` ADD CONSTRAINT `fk_antecedente_mascota` FOREIGN KEY (`id_mascota`) REFERENCES `mascota` (`id_mascota`) ON DELETE RESTRICT;

ALTER TABLE `jaula` ADD CONSTRAINT `fk_jaula_sede` FOREIGN KEY (`id_sede`) REFERENCES `sede` (`id_sede`) ON DELETE RESTRICT;

ALTER TABLE `hospitalizacion` ADD CONSTRAINT `fk_hosp_mascota` FOREIGN KEY (`id_mascota`) REFERENCES `mascota` (`id_mascota`) ON DELETE RESTRICT;

ALTER TABLE `hospitalizacion` ADD CONSTRAINT `fk_hosp_jaula` FOREIGN KEY (`id_jaula`) REFERENCES `jaula` (`id_jaula`) ON DELETE RESTRICT;

ALTER TABLE `hospitalizacion` ADD CONSTRAINT `fk_hosp_historia` FOREIGN KEY (`id_historia`, `id_mascota`) REFERENCES `historia_clinica` (`id_historia`, `id_mascota`) ON DELETE RESTRICT;

ALTER TABLE `documento` ADD CONSTRAINT `fk_documento_historia` FOREIGN KEY (`id_historia`) REFERENCES `historia_clinica` (`id_historia`) ON DELETE RESTRICT;

ALTER TABLE `documento` ADD CONSTRAINT `fk_documento_veterinario` FOREIGN KEY (`id_veterinario`) REFERENCES `veterinario` (`id_veterinario`) ON DELETE RESTRICT;

ALTER TABLE `vacunacion` ADD CONSTRAINT `fk_vacunacion_mascota` FOREIGN KEY (`id_mascota`) REFERENCES `mascota` (`id_mascota`) ON DELETE RESTRICT;

ALTER TABLE `vacunacion` ADD CONSTRAINT `fk_vacunacion_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicio` (`id_servicio`) ON DELETE RESTRICT;

ALTER TABLE `vacunacion` ADD CONSTRAINT `fk_vacunacion_veterinario` FOREIGN KEY (`id_veterinario`) REFERENCES `veterinario` (`id_veterinario`) ON DELETE RESTRICT;

ALTER TABLE `vacunacion` ADD CONSTRAINT `fk_vacunacion_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote_medicamento` (`id_lote`) ON DELETE RESTRICT;

ALTER TABLE `recordatorio_vacunacion` ADD CONSTRAINT `fk_recordatorio_mascota` FOREIGN KEY (`id_mascota`) REFERENCES `mascota` (`id_mascota`) ON DELETE RESTRICT;

ALTER TABLE `recordatorio_vacunacion` ADD CONSTRAINT `fk_recordatorio_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicio` (`id_servicio`) ON DELETE RESTRICT;

ALTER TABLE `recordatorio_vacunacion` ADD CONSTRAINT `fk_recordatorio_vacunacion` FOREIGN KEY (`id_vacunacion_cumplida`, `id_mascota`, `id_servicio`) REFERENCES `vacunacion` (`id_vacunacion`, `id_mascota`, `id_servicio`) ON DELETE RESTRICT;

ALTER TABLE `proveedor_telefono` ADD CONSTRAINT `fk_proveedor_telefono` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`) ON DELETE CASCADE;

ALTER TABLE `proveedor_email` ADD CONSTRAINT `fk_proveedor_email` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`) ON DELETE CASCADE;

ALTER TABLE `medicamento` ADD CONSTRAINT `fk_medicamento_laboratorio` FOREIGN KEY (`id_laboratorio`) REFERENCES `laboratorio` (`id_laboratorio`) ON DELETE RESTRICT;

ALTER TABLE `medicamento` ADD CONSTRAINT `fk_medicamento_presentacion` FOREIGN KEY (`id_presentacion`) REFERENCES `presentacion` (`id_presentacion`) ON DELETE RESTRICT;

ALTER TABLE `medicamento_principio_activo` ADD CONSTRAINT `fk_medpa_medicamento` FOREIGN KEY (`id_medicamento`) REFERENCES `medicamento` (`id_medicamento`) ON DELETE CASCADE;

ALTER TABLE `medicamento_principio_activo` ADD CONSTRAINT `fk_medpa_principio` FOREIGN KEY (`id_principio_activo`) REFERENCES `principio_activo` (`id_principio_activo`) ON DELETE RESTRICT;

ALTER TABLE `medicamento_sede` ADD CONSTRAINT `fk_medsede_medicamento` FOREIGN KEY (`id_medicamento`) REFERENCES `medicamento` (`id_medicamento`) ON DELETE RESTRICT;

ALTER TABLE `medicamento_sede` ADD CONSTRAINT `fk_medsede_sede` FOREIGN KEY (`id_sede`) REFERENCES `sede` (`id_sede`) ON DELETE RESTRICT;

ALTER TABLE `lote_medicamento` ADD CONSTRAINT `fk_lote_medsede` FOREIGN KEY (`id_medicamento_sede`) REFERENCES `medicamento_sede` (`id_medicamento_sede`) ON DELETE RESTRICT;

ALTER TABLE `lote_medicamento` ADD CONSTRAINT `fk_lote_proveedor` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedor` (`id_proveedor`) ON DELETE RESTRICT;

ALTER TABLE `tratamiento_medicamento` ADD CONSTRAINT `fk_tratamiento_historia` FOREIGN KEY (`id_historia`) REFERENCES `historia_clinica` (`id_historia`) ON DELETE RESTRICT;

ALTER TABLE `tratamiento_medicamento` ADD CONSTRAINT `fk_tratamiento_lote` FOREIGN KEY (`id_lote`) REFERENCES `lote_medicamento` (`id_lote`) ON DELETE RESTRICT;

ALTER TABLE `tratamiento_medicamento` ADD CONSTRAINT `fk_tratamiento_unidad` FOREIGN KEY (`id_unidad_dosis`) REFERENCES `unidad_medida` (`id_unidad`) ON DELETE RESTRICT;

ALTER TABLE `factura` ADD CONSTRAINT `fk_factura_propietario` FOREIGN KEY (`id_propietario`) REFERENCES `propietario` (`id_propietario`) ON DELETE RESTRICT;

ALTER TABLE `factura` ADD CONSTRAINT `fk_factura_sede` FOREIGN KEY (`id_sede`) REFERENCES `sede` (`id_sede`) ON DELETE RESTRICT;

ALTER TABLE `detalle_factura` ADD CONSTRAINT `fk_detalle_factura` FOREIGN KEY (`id_factura`) REFERENCES `factura` (`id_factura`) ON DELETE RESTRICT;

ALTER TABLE `detalle_factura_servicio` ADD CONSTRAINT `fk_detsrv_detalle` FOREIGN KEY (`id_detalle`, `tipo_item`) REFERENCES `detalle_factura` (`id_detalle`, `tipo_item`) ON DELETE CASCADE;

ALTER TABLE `detalle_factura_servicio` ADD CONSTRAINT `fk_detsrv_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicio` (`id_servicio`) ON DELETE RESTRICT;

ALTER TABLE `detalle_factura_medicamento` ADD CONSTRAINT `fk_detmed_detalle` FOREIGN KEY (`id_detalle`, `tipo_item`) REFERENCES `detalle_factura` (`id_detalle`, `tipo_item`) ON DELETE CASCADE;

ALTER TABLE `detalle_factura_medicamento` ADD CONSTRAINT `fk_detmed_medicamento` FOREIGN KEY (`id_medicamento`) REFERENCES `medicamento` (`id_medicamento`) ON DELETE RESTRICT;

ALTER TABLE `pago` ADD CONSTRAINT `fk_pago_factura` FOREIGN KEY (`id_factura`) REFERENCES `factura` (`id_factura`) ON DELETE RESTRICT;

ALTER TABLE `pago` ADD CONSTRAINT `fk_pago_medio` FOREIGN KEY (`id_medio_pago`) REFERENCES `medio_pago` (`id_medio_pago`) ON DELETE RESTRICT;
