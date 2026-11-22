DROP TABLE IF EXISTS eventos_replica CASCADE;
DROP TABLE IF EXISTS admisiones CASCADE;
DROP TABLE IF EXISTS pacientes CASCADE;
DROP TABLE IF EXISTS medicos CASCADE;
DROP TABLE IF EXISTS servicios CASCADE;
DROP TABLE IF EXISTS diagnosticos CASCADE;
DROP TABLE IF EXISTS medicamentos CASCADE;

CREATE TABLE pacientes (
    paciente_id INTEGER PRIMARY KEY,
    documento VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(60) NOT NULL,
    apellido VARCHAR(60) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero CHAR(1) NOT NULL CHECK (genero IN ('F','M','O')),
    eps VARCHAR(80) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE medicos (
    medico_id INTEGER PRIMARY KEY,
    registro_profesional VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(60) NOT NULL,
    apellido VARCHAR(60) NOT NULL,
    especialidad VARCHAR(60) NOT NULL
);

CREATE TABLE servicios (
    servicio_id INTEGER PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL,
    area VARCHAR(60) NOT NULL
);

CREATE TABLE diagnosticos (
    codigo_cie10 VARCHAR(10) PRIMARY KEY,
    descripcion VARCHAR(160) NOT NULL
);

CREATE TABLE medicamentos (
    medicamento_id INTEGER PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    via VARCHAR(30) NOT NULL,
    concentracion VARCHAR(40) NOT NULL
);

CREATE TABLE admisiones (
    admision_id INTEGER PRIMARY KEY,
    paciente_id INTEGER NOT NULL REFERENCES pacientes(paciente_id),
    medico_id INTEGER NOT NULL REFERENCES medicos(medico_id),
    servicio_id INTEGER NOT NULL REFERENCES servicios(servicio_id),
    codigo_cie10 VARCHAR(10) NOT NULL REFERENCES diagnosticos(codigo_cie10),
    fecha_ingreso TIMESTAMP NOT NULL,
    fecha_egreso TIMESTAMP,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('ACTIVA','EGRESADA','ANULADA')),
    cama VARCHAR(10) NOT NULL
);

CREATE TABLE eventos_replica (
    evento_id BIGINT PRIMARY KEY,
    paciente_id INTEGER NOT NULL REFERENCES pacientes(paciente_id),
    admision_id INTEGER REFERENCES admisiones(admision_id),
    tipo VARCHAR(30) NOT NULL,
    registrado_en TIMESTAMP NOT NULL,
    payload JSONB NOT NULL
);

CREATE INDEX ix_eventos_replica_paciente_tiempo ON eventos_replica (paciente_id, registrado_en DESC);
CREATE INDEX ix_eventos_replica_tipo_tiempo ON eventos_replica (tipo, registrado_en DESC);
CREATE INDEX ix_admisiones_estado ON admisiones (estado, fecha_ingreso DESC);
