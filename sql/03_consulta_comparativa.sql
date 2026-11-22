EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT e.registrado_en,
       e.payload->>'sistolica' AS sistolica,
       e.payload->>'diastolica' AS diastolica
FROM eventos_replica e
WHERE e.paciente_id = 2
  AND e.tipo = 'signo_vital'
  AND e.registrado_en >= now() - interval '24 hours'
ORDER BY e.registrado_en DESC;

DROP TABLE IF EXISTS metricas_postgres;
CREATE TABLE metricas_postgres (
    motor VARCHAR(30),
    operacion VARCHAR(60),
    repeticiones INTEGER,
    promedio_ms NUMERIC,
    p95_ms NUMERIC,
    filas BIGINT,
    ejecutado_en TIMESTAMPTZ
);

DO $$
DECLARE
    t0 TIMESTAMPTZ;
    muestras NUMERIC[] := ARRAY[]::NUMERIC[];
    prom DOUBLE PRECISION;
    p95 DOUBLE PRECISION;
    filas BIGINT := 0;
    i INTEGER;
    r RECORD;
BEGIN
    FOR i IN 1..30 LOOP
        t0 := clock_timestamp();
        filas := 0;
        FOR r IN
            SELECT e.registrado_en,
                   e.payload->>'sistolica' AS sistolica,
                   e.payload->>'diastolica' AS diastolica
            FROM eventos_replica e
            WHERE e.paciente_id = 2
              AND e.tipo = 'signo_vital'
              AND e.registrado_en >= now() - interval '24 hours'
            ORDER BY e.registrado_en DESC
        LOOP
            filas := filas + 1;
        END LOOP;
        muestras := array_append(muestras, EXTRACT(EPOCH FROM clock_timestamp() - t0) * 1000);
    END LOOP;
    SELECT avg(x), percentile_cont(0.95) WITHIN GROUP (ORDER BY x)
      INTO prom, p95
      FROM unnest(muestras) AS x;
    INSERT INTO metricas_postgres
    VALUES ('PostgreSQL', 'historial_tension_24h', 30, round(prom::NUMERIC, 3), round(p95::NUMERIC, 3), filas, now());
    RAISE NOTICE 'postgres promedio_ms=% p95_ms=% filas=%', round(prom::NUMERIC, 3), round(p95::NUMERIC, 3), filas;
END $$;

\copy (SELECT motor, operacion, repeticiones, promedio_ms, p95_ms, filas, ejecutado_en FROM metricas_postgres) TO 'resultados/metricas_postgres.csv' CSV HEADER
