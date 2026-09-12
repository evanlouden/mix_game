"""Export the supplied workbook losslessly using Python's standard library."""
import json
from pathlib import Path
import xml.etree.ElementTree as ET
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
NS = {'m': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
with ZipFile(ROOT / 'poker_variant_mechanics_normalized.xlsx') as archive:
    strings = []
    if 'xl/sharedStrings.xml' in archive.namelist():
        strings = [''.join(node.itertext()) for node in ET.fromstring(archive.read('xl/sharedStrings.xml')).findall('m:si', NS)]
    sheets = {}
    names = ['variants', 'definitions', 'sources', 'raw_pages', 'model', 'sequence', 'hand_rules', 'tags']
    for number, name in enumerate(names, 1):
        rows = []
        for row in ET.fromstring(archive.read(f'xl/worksheets/sheet{number}.xml')).findall('.//m:row', NS):
            values = {}
            for cell in row:
                column = ''.join(c for c in cell.get('r') if c.isalpha())
                value = cell.find('m:v', NS)
                values[column] = strings[int(value.text)] if cell.get('t') == 's' else ''.join(cell.itertext())
            rows.append(values)
        header = rows.pop(0)
        sheets[name] = [{label: row.get(column, '') for column, label in header.items()} for row in rows]
    (ROOT / 'db/data/workbook.json').write_text(json.dumps(sheets, ensure_ascii=False, indent=2) + '\n')
    print(f"Exported {len(sheets['variants'])} variants and all supporting sheets.")
