const ctx = db.getSiblingDB('hibrido_clinico');
ctx.eventos_clinicos.drop();
ctx.dispositivos.drop();
ctx.createCollection('eventos_clinicos', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['paciente_id', 'admision_id', 'tipo', 'registrado_en', 'payload'],
      properties: {
        paciente_id: { bsonType: 'number' },
        admision_id: { bsonType: 'number' },
        tipo: { enum: ['signo_vital', 'sensor', 'teleconsulta', 'log'] },
        registrado_en: { bsonType: 'date' },
        payload: { bsonType: 'object' }
      }
    }
  }
});
ctx.createCollection('dispositivos');
ctx.eventos_clinicos.createIndex({ paciente_id: 1, registrado_en: -1 }, { name: 'ix_paciente_tiempo' });
ctx.eventos_clinicos.createIndex({ tipo: 1, registrado_en: -1 }, { name: 'ix_tipo_tiempo' });
ctx.eventos_clinicos.createIndex({ 'payload.dispositivo_id': 1 }, { name: 'ix_dispositivo' });
ctx.dispositivos.insertMany([
  { dispositivo_id: 101, paciente_id: 1, tipo: 'wearable', modelo: 'CardioBand X2', activo: true },
  { dispositivo_id: 102, paciente_id: 2, tipo: 'wearable', modelo: 'CardioBand X2', activo: true },
  { dispositivo_id: 103, paciente_id: 3, tipo: 'sensor_clinico', modelo: 'GlucoSense 4', activo: true },
  { dispositivo_id: 104, paciente_id: 4, tipo: 'sensor_clinico', modelo: 'GlucoSense 4', activo: true },
  { dispositivo_id: 105, paciente_id: 5, tipo: 'wearable', modelo: 'PulseWatch S', activo: false }
]);
print('colecciones:', ctx.getCollectionNames().join(', '));
print('indices eventos:', ctx.eventos_clinicos.getIndexes().length);
print('dispositivos:', ctx.dispositivos.countDocuments());
