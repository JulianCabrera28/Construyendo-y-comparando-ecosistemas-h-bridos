const fs = require('fs');
const ctx = db.getSiblingDB('hibrido_clinico');
const datos = JSON.parse(fs.readFileSync('datos/eventos.json', 'utf8'));
const documentos = datos.map(function (d) {
  d.registrado_en = new Date(d.registrado_en);
  return d;
});
const inicio = Date.now();
for (let i = 0; i < documentos.length; i += 1000) {
  ctx.eventos_clinicos.insertMany(documentos.slice(i, i + 1000), { ordered: false });
}
const elapsed = Date.now() - inicio;
print('eventos insertados:', ctx.eventos_clinicos.countDocuments());
print('tiempo_ingesta_ms:', elapsed);
print('eventos_por_segundo:', Math.round(documentos.length / (elapsed / 1000)));
