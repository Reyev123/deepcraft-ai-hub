#!/bin/bash
set -euo pipefail

MASTER_JSON_PATH="${1:-./master.json}"
OUTPUT_PATH="${2:-./master_priority_order.txt}"

python3 - "$MASTER_JSON_PATH" "$OUTPUT_PATH" <<'PY'
import json
import sys
from pathlib import Path

master_json_path = Path(sys.argv[1])
output_path = Path(sys.argv[2])

if not master_json_path.exists():
    raise SystemExit(f"Error: master.json not found at {master_json_path}")

with master_json_path.open('r', encoding='utf-8') as master_file:
    data = json.load(master_file)

if not isinstance(data, dict):
    raise SystemExit('Error: Expected master.json to contain a top-level object')


def format_type(type_value):
    if isinstance(type_value, list):
        return ' | '.join(str(item) for item in type_value)
    if type_value is None:
        return ''
    return str(type_value)


lines = ['priority_order\ttype\ttitle']
for index, value in enumerate(data.values(), start=1):
    if not isinstance(value, dict):
        type_text = ''
        title_text = str(value)
    else:
        type_text = format_type(value.get('Type', value.get('type', '')))
        title_text = str(value.get('title', ''))

    lines.append(f'{index}\t{type_text}\t{title_text}')

output_path.write_text('\n'.join(lines) + '\n', encoding='utf-8')

print(f'Master priority order written to {output_path}')
print('--- master priority order ---')
for line in lines:
    print(line)
print('--- end master priority order ---')
PY
