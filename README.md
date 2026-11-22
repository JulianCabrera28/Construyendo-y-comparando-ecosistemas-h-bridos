# Construyendo y comparando ecosistemas híbridos

**Estudiante:** Julian Camilo Cabrera Echeverri  
**Asignatura:** Bases de Datos II  
**Motores:** PostgreSQL 17.12 y MongoDB 8.0.14

Arquitectura híbrida para un subsistema de hospitalización. PostgreSQL concentra la capa ACID (identidad del paciente, profesionales, catálogos y admisiones) y MongoDB la capa BASE (telemetría de signos vitales, sensores, teleconsultas y logs con payload semiestructurado). Se incluye la ingesta simulada de 10.000 eventos y la comparación de latencia de una misma operación en ambos motores. Todos los datos son ficticios.

## Estructura del repositorio

| Ruta | Contenido |
|---|---|
| `sql/00_base_datos.sql` | Creación de la base `hibrido_clinico`. |
| `sql/01_esquema.sql` | Tablas, llaves foráneas, restricciones e índices. |
| `sql/02_datos.sql` | Datos maestros y carga de los 10.000 eventos. |
| `sql/03_consulta_comparativa.sql` | EXPLAIN ANALYZE y medición de 30 repeticiones. |
| `sql/04_consultas_avanzadas.sql` | JOIN, agrupación por hora y funciones de ventana. |
| `nosql/01_esquema.js` | Colecciones, validador `$jsonSchema` e índices. |
| `nosql/02_ingesta_masiva.js` | Ingesta por lotes de los 10.000 eventos. |
| `nosql/03_consulta_comparativa.js` | Explain y medición de 30 repeticiones. |
| `nosql/04_consultas_avanzadas.js` | `$group`, `$lookup`, `$dateTrunc` y `$round`. |
| `datos/generar_eventos.py` | Generador determinista de eventos (semilla fija). |
| `datos/eventos.csv` | Eventos en formato CSV para PostgreSQL. |
| `datos/eventos.json` | Los mismos eventos en formato JSON para MongoDB. |
| `resultados/metricas.csv` | Métricas consolidadas de latencia. |
| `resultados/metricas_postgres.csv` | Métrica obtenida en PostgreSQL. |
| `resultados/metricas_mongodb.csv` | Métrica obtenida en MongoDB. |
| `resultados/grafico_latencia.png` | Gráfico comparativo de promedio y p95. |
| `resultados/salida_*.txt` | Salidas reales de cada ejecución. |
| `capturas/` | Capturas de ejecución de ambos motores. |

## Ejecución desde cero

Trabajar desde la raíz del repositorio.

### 1. Generar los datos de prueba

```powershell
python datos\generar_eventos.py
```

### 2. Capa PostgreSQL

Usuario `postgres`, contraseña `postgres`, puerto `5432`.

```powershell
$env:PGPASSWORD='postgres'
$psql='C:\Program Files\PostgreSQL\17\bin\psql.exe'
& $psql -h 127.0.0.1 -U postgres -d postgres -f sql\00_base_datos.sql
& $psql -h 127.0.0.1 -U postgres -d hibrido_clinico -f sql\01_esquema.sql
& $psql -h 127.0.0.1 -U postgres -d hibrido_clinico -f sql\02_datos.sql
& $psql -h 127.0.0.1 -U postgres -d hibrido_clinico -f sql\03_consulta_comparativa.sql
& $psql -h 127.0.0.1 -U postgres -d hibrido_clinico -f sql\04_consultas_avanzadas.sql
```

### 3. Capa MongoDB

```powershell
mongod --dbpath datos_mongo --port 27018 --bind_ip 127.0.0.1
mongosh --port 27018 --file nosql\01_esquema.js
mongosh --port 27018 --file nosql\02_ingesta_masiva.js
mongosh --port 27018 --file nosql\03_consulta_comparativa.js
mongosh --port 27018 --file nosql\04_consultas_avanzadas.js
```

La carpeta `datos_mongo` se crea localmente al iniciar el servidor; no hace falta versionarla.

## Operación comparada e índices

Operación: *historial de tensión arterial de un paciente en las últimas 24 horas*. Devuelve 409 filas en ambos motores.

- PostgreSQL: índice compuesto `ix_eventos_replica_paciente_tiempo (paciente_id, registrado_en DESC)` y `EXPLAIN ANALYZE`.
- MongoDB: índice `ix_paciente_tiempo { paciente_id: 1, registrado_en: -1 }` y `explain('executionStats')`.

## Resultados

| Motor | Repeticiones | Promedio (ms) | p95 (ms) | Filas |
|---|---:|---:|---:|---:|
| PostgreSQL 17 | 30 | 0.363 | 0.420 | 409 |
| MongoDB 8 | 30 | 3.553 | 4.646 | 409 |

La ingesta masiva completó 10.000 eventos en 152 ms (aproximadamente 65.789 eventos/s). En la consulta puntual indexada PostgreSQL fue unas 9,8 veces más rápido; MongoDB mostró su ventaja en la velocidad de escritura y en la flexibilidad del documento para eventos de distinta forma.
