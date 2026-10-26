#!/usr/bin/env python3
"""Comprobación autónoma, sin dependencias externas, de los datos del proyecto."""
from pathlib import Path
from collections import Counter
import csv

ROOT = Path(__file__).resolve().parents[1]
SOURCES = {
    'IDH': ('human-development-index.csv', 'Human Development Index'),
    'IDH-D': ('inequality-adjusted-human-development-index.csv', 'Inequality-adjusted Human Development Index'),
    'AHDI': ('augmented-human-development-index.csv', 'Augmented Human Development Index (AHDI)'),
}

def read(name, col):
    with (ROOT / 'data' / name).open(encoding='utf-8-sig', newline='') as f:
        table = list(csv.DictReader(f))
    assert table and all(k in table[0] for k in ['Entity', 'Code', 'Year', col, 'World region according to OWID'])
    return [r for r in table if len(r.get('Code','')) == 3 and r['Code'].isalpha()
            and r.get('World region according to OWID') and r.get(col)]

def top30(rows, col, year=2023):
    filtered = [r for r in rows if int(r['Year']) == year]
    mx = next(float(r[col]) for r in filtered if r['Code'] == 'MEX')
    lower = sorted((r for r in filtered if r['Code'] != 'MEX' and float(r[col]) < mx),
                   key=lambda r: (-float(r[col]), r['Entity']))
    return filtered, mx, lower[:30], len(lower)

tables={}
for key,(name,col) in SOURCES.items():
    rows = read(name,col)
    tables[key]=rows
    years=sorted(set(int(r['Year']) for r in rows))
    print(f'{key}: {len(rows)} registros; {len(set(r["Code"] for r in rows))} países; años {years[0]}–{years[-1]}')
    if key!='AHDI':
        filtered,mx,first30,below=top30(rows,col)
        print(f'  2023: {len(filtered)} países; México={mx:.3f}; debajo={below}; primeros 30={len(first30)}')
        assert len(first30)==30
    else:
        assert years[-1]==2020
        assert not any(r['Year']=='2023' for r in rows)

hd = top30(tables['IDH'], SOURCES['IDH'][1])[2]
ih = top30(tables['IDH-D'], SOURCES['IDH-D'][1])[2]
coincidencias=len({r['Code'] for r in hd}&{r['Code'] for r in ih})
print('Coincidencia de listas 2023 (30 vs 30):',coincidencias)
assert top30(tables['IDH'], SOURCES['IDH'][1])[3]==111
assert top30(tables['IDH-D'], SOURCES['IDH-D'][1])[3]==96
assert coincidencias==17
print('VALIDACIÓN CORRECTA.')
