INSERT INTO pacientes (paciente_id, documento, nombre, apellido, fecha_nacimiento, genero, eps, activo) VALUES
(1, 'CC-1023456789', 'Laura', 'Restrepo', '1978-04-12', 'F', 'EPS Suramericana', TRUE),
(2, 'CC-1034567890', 'Andres', 'Vidales', '1965-09-23', 'M', 'Nueva EPS', TRUE),
(3, 'CC-1045678901', 'Marta', 'Cabrera', '1990-01-07', 'F', 'Compensar', TRUE),
(4, 'CC-1056789012', 'Jorge', 'Echeverri', '1958-11-30', 'M', 'Medimas', TRUE),
(5, 'CC-1067890123', 'Sofia', 'Ramirez', '2001-06-18', 'F', 'Sura', TRUE);

INSERT INTO medicos (medico_id, registro_profesional, nombre, apellido, especialidad) VALUES
(1, 'MP-17890', 'Carlos', 'Mejia', 'Medicina Interna'),
(2, 'MP-20431', 'Claudia', 'Ospina', 'Cardiologia'),
(3, 'MP-23117', 'Luis', 'Quintero', 'Ortopedia'),
(4, 'MP-25984', 'Ana', 'Torres', 'Medicina Familiar');

INSERT INTO servicios (servicio_id, codigo, nombre, area) VALUES
(1, 'MED-INT', 'Medicina Interna', 'Hospitalizacion'),
(2, 'CARDIO', 'Cardiologia', 'Hospitalizacion'),
(3, 'ORTO', 'Ortopedia', 'Hospitalizacion'),
(4, 'UCI', 'Cuidado Intensivo', 'Criticos');

INSERT INTO diagnosticos (codigo_cie10, descripcion) VALUES
('I10', 'Hipertension arterial esencial'),
('E11.9', 'Diabetes mellitus tipo 2 sin complicaciones'),
('J18.9', 'Neumonia no especificada'),
('M54.5', 'Lumbalgia baja');

INSERT INTO medicamentos (medicamento_id, nombre, via, concentracion) VALUES
(1, 'Losartan', 'Oral', '50 mg'),
(2, 'Metformina', 'Oral', '850 mg'),
(3, 'Insulina glargina', 'Subcutanea', '100 UI/mL'),
(4, 'Ceftriaxona', 'Intravenosa', '1 g');

INSERT INTO admisiones (admision_id, paciente_id, medico_id, servicio_id, codigo_cie10, fecha_ingreso, fecha_egreso, estado, cama) VALUES
(1, 1, 1, 1, 'E11.9', now() - interval '3 days', NULL, 'ACTIVA', 'C-101'),
(2, 2, 2, 2, 'I10', now() - interval '2 days', NULL, 'ACTIVA', 'C-204'),
(3, 3, 4, 1, 'J18.9', now() - interval '5 days', now() - interval '2 days', 'EGRESADA', 'C-108'),
(4, 4, 3, 3, 'M54.5', now() - interval '4 days', NULL, 'ACTIVA', 'C-312'),
(5, 5, 1, 4, 'J18.9', now() - interval '6 days', now() - interval '3 days', 'EGRESADA', 'UCI-02'),
(6, 1, 2, 2, 'I10', now() - interval '1 day', NULL, 'ACTIVA', 'C-206');

\copy eventos_replica (evento_id, paciente_id, admision_id, tipo, registrado_en, payload) FROM 'datos/eventos.csv' WITH (FORMAT csv, HEADER true)

ANALYZE pacientes;
ANALYZE admisiones;
ANALYZE eventos_replica;
