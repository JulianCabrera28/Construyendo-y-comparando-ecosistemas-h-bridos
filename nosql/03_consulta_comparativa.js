const fs = require('fs');
const ctx = db.getSiblingDB('hibrido_clinico');
const limite = new Date(Date.now() - 24 * 60 * 60 * 1000);
const filtro = { paciente_id: 2, tipo: 'signo_vital', registrado_en: { $gte: limite } };
const ejecutar = function () {
  return ctx.eventos_clinicos.find(filtro, {
    _id: 0,
    registrado_en: 1,
    'payload.sistolica': 1,
    'payload.diastolica': 1
  }).sort({ registrado_en: -1 }).toArray();
};
const muestra = ejecutar();
print('filas_devueltas:', muestra.length);
printjson(muestra.slice(0, 3));
const stats = ctx.eventos_clinicos.find(filtro).sort({ registrado_en: -1 }).explain('executionStats').executionStats;
print('explain_execution_ms:', stats.executionTimeMillis);
print('explain_docs_examined:', stats.totalDocsExamined);
print('explain_keys_examined:', stats.totalKeysExamined);
const muestras = [];
for (let i = 0; i < 30; i++) {
  const t0 = process.hrtime.bigint();
  ejecutar();
  muestras.push(Number(process.hrtime.bigint() - t0) / 1000000);
}
const ordenadas = muestras.slice().sort(function (a, b) { return a - b; });
const promedio = muestras.reduce(function (a, b) { return a + b; }, 0) / muestras.length;
const p95 = ordenadas[Math.ceil(0.95 * ordenadas.length) - 1];
const fila = 'MongoDB,historial_tension_24h,30,' + promedio.toFixed(3) + ',' + p95.toFixed(3) + ',' + muestra.length + ',' + new Date().toISOString() + '\n';
fs.writeFileSync('resultados/metricas_mongodb.csv', 'motor,operacion,repeticiones,promedio_ms,p95_ms,filas,ejecutado_en\n' + fila);
print('mongodb promedio_ms:', promedio.toFixed(3));
print('mongodb p95_ms:', p95.toFixed(3));
