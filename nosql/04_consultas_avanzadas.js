const ctx = db.getSiblingDB('hibrido_clinico');
print('=== eventos por tipo y paciente ===');
printjson(ctx.eventos_clinicos.aggregate([
  { $group: { _id: { paciente_id: '$paciente_id', tipo: '$tipo' }, total: { $sum: 1 } } },
  { $sort: { total: -1 } },
  { $project: { _id: 0, paciente_id: '$_id.paciente_id', tipo: '$_id.tipo', total: 1 } }
]).toArray());
print('=== telemetria por dispositivo ===');
printjson(ctx.eventos_clinicos.aggregate([
  { $match: { tipo: 'sensor' } },
  { $lookup: { from: 'dispositivos', localField: 'payload.dispositivo_id', foreignField: 'dispositivo_id', as: 'dispositivo' } },
  { $unwind: '$dispositivo' },
  { $group: { _id: '$dispositivo.modelo', lecturas: { $sum: 1 }, glucosa_promedio: { $avg: '$payload.glucosa' } } },
  { $project: { _id: 1, lecturas: 1, glucosa_promedio: { $round: ['$glucosa_promedio', 1] } } },
  { $sort: { lecturas: -1 } }
]).toArray());
print('=== ventanas horarias de tension ===');
printjson(ctx.eventos_clinicos.aggregate([
  { $match: { tipo: 'signo_vital', registrado_en: { $gte: new Date(Date.now() - 48 * 60 * 60 * 1000) } } },
  { $group: { _id: { $dateTrunc: { date: '$registrado_en', unit: 'hour' } }, controles: { $sum: 1 }, sistolica_promedio: { $avg: '$payload.sistolica' }, sistolica_maxima: { $max: '$payload.sistolica' } } },
  { $project: { _id: 1, controles: 1, sistolica_promedio: { $round: ['$sistolica_promedio', 1] }, sistolica_maxima: 1 } },
  { $sort: { _id: -1 } }
]).toArray());
