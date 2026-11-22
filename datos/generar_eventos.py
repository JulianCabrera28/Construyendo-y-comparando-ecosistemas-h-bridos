import csv
import json
import random
from datetime import datetime, timedelta, timezone

random.seed(20261122)
now = datetime.now(timezone.utc)
tipos = ['signo_vital'] * 60 + ['sensor'] * 25 + ['teleconsulta'] * 10 + ['log'] * 5
pacientes = [1, 2, 3, 4, 5]
admisiones = {1: [1, 6], 2: [2], 3: [3], 4: [4], 5: [5]}
dispositivos = [101, 102, 103, 104, 105]
motivos = ['control de tension', 'seguimiento postoperatorio', 'ajuste de medicacion', 'control glucemico']
acciones = ['sincronizacion', 'lectura automatica', 'alerta de bateria', 'cierre de sesion']
severidades = ['INFO', 'INFO', 'WARNING', 'DEBUG']

eventos = []
for evento_id in range(1, 10001):
    tipo = random.choice(tipos)
    paciente_id = random.choice(pacientes)
    registrado = now - timedelta(minutes=random.randint(1, 4320))
    if tipo == 'signo_vital':
        payload = {
            'sistolica': random.randint(100, 185),
            'diastolica': random.randint(60, 108),
            'frecuencia_cardiaca': random.randint(55, 122),
            'spo2': random.randint(88, 100),
            'temperatura': round(36 + random.random() * 2, 1)
        }
    elif tipo == 'sensor':
        payload = {
            'dispositivo_id': random.choice(dispositivos),
            'glucosa': random.randint(70, 185),
            'pasos': random.randint(0, 9000),
            'bpm': random.randint(50, 140),
            'bateria': random.randint(8, 100)
        }
    elif tipo == 'teleconsulta':
        payload = {
            'motivo': random.choice(motivos),
            'duracion_min': random.randint(5, 35),
            'medico_id': random.randint(1, 4),
            'notas': 'seguimiento ambulatorio sin hallazgos críticos'
        }
    else:
        payload = {
            'accion': random.choice(acciones),
            'codigo': 'LOG-' + str(random.randint(100, 999)),
            'severidad': random.choice(severidades)
        }
    eventos.append({
        'evento_id': evento_id,
        'paciente_id': paciente_id,
        'admision_id': random.choice(admisiones[paciente_id]),
        'tipo': tipo,
        'registrado_en': registrado.isoformat().replace('+00:00', 'Z'),
        'registrado_sql': registrado.strftime('%Y-%m-%d %H:%M:%S'),
        'payload': payload
    })

with open('datos/eventos.json', 'w', encoding='utf-8') as archivo:
    json.dump([{k: v for k, v in e.items() if k != 'registrado_sql'} for e in eventos], archivo, ensure_ascii=False)

with open('datos/eventos.csv', 'w', newline='', encoding='utf-8') as archivo:
    escritor = csv.writer(archivo)
    escritor.writerow(['evento_id', 'paciente_id', 'admision_id', 'tipo', 'registrado_en', 'payload'])
    for e in eventos:
        escritor.writerow([e['evento_id'], e['paciente_id'], e['admision_id'], e['tipo'], e['registrado_sql'], json.dumps(e['payload'], ensure_ascii=False)])

print('eventos generados:', len(eventos))
print('signo_vital:', sum(1 for e in eventos if e['tipo'] == 'signo_vital'))
print('ultimas_24h_paciente_2:', sum(1 for e in eventos if e['paciente_id'] == 2 and e['tipo'] == 'signo_vital' and (now - datetime.fromisoformat(e['registrado_en'].replace('Z', '+00:00'))).total_seconds() <= 86400))
