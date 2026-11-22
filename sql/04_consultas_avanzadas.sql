SELECT p.nombre, p.apellido, s.nombre AS servicio, m.nombre AS medico,
       a.cama, a.fecha_ingreso, d.descripcion AS diagnostico
FROM admisiones a
JOIN pacientes p ON p.paciente_id = a.paciente_id
JOIN servicios s ON s.servicio_id = a.servicio_id
JOIN medicos m ON m.medico_id = a.medico_id
JOIN diagnosticos d ON d.codigo_cie10 = a.codigo_cie10
WHERE a.estado = 'ACTIVA'
ORDER BY a.fecha_ingreso DESC;

SELECT date_trunc('hour', registrado_en) AS hora,
       count(*) AS controles,
       round(avg((payload->>'sistolica')::numeric), 1) AS sistolica_promedio,
       round(avg((payload->>'diastolica')::numeric), 1) AS diastolica_promedio,
       max((payload->>'sistolica')::numeric) AS sistolica_maxima,
       lag(count(*)) OVER (ORDER BY date_trunc('hour', registrado_en)) AS controles_hora_anterior
FROM eventos_replica
WHERE tipo = 'signo_vital'
  AND registrado_en >= now() - interval '48 hours'
GROUP BY date_trunc('hour', registrado_en)
ORDER BY hora DESC;

SELECT p.nombre, p.apellido, count(*) AS total_eventos,
       rank() OVER (ORDER BY count(*) DESC) AS puesto
FROM eventos_replica e
JOIN pacientes p ON p.paciente_id = e.paciente_id
GROUP BY p.paciente_id, p.nombre, p.apellido
ORDER BY puesto;
