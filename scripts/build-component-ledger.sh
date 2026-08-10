#!/usr/bin/env bash
set -euo pipefail

# Make this script executable if not already
chmod +x "$0"

delta_dir="${1:?Usage: build-component-ledger.sh <delta-dir> <tag> <from> <to>}"
tag="${2:?tag required}"
from_ref="${3:?from required}"
to_ref="${4:?to required}"

python3 - "$delta_dir" "$tag" "$from_ref" "$to_ref" <<'PY'
import csv, pathlib, sys, xml.etree.ElementTree as ET
root_dir, tag, from_ref, to_ref = sys.argv[1:]
rows=[]
for action, rel in [('deploy','package/package.xml'), ('delete','destructiveChanges/destructiveChanges.xml')]:
    p=pathlib.Path(root_dir)/rel
    if not p.exists():
        continue
    root=ET.parse(p).getroot()
    ns={'m':'http://soap.sforce.com/2006/04/metadata'}
    for t in root.findall('m:types',ns):
        name=t.findtext('m:name',default='',namespaces=ns)
        for member in t.findall('m:members',ns):
            rows.append([tag,action,name,member.text or '',from_ref,to_ref])
out=pathlib.Path(root_dir)/'component-version-map.csv'
with out.open('w',newline='',encoding='utf-8') as f:
    w=csv.writer(f)
    w.writerow(['release_tag','action','metadata_type','component','from_revision','to_revision'])
    w.writerows(sorted(rows,key=lambda r:(r[1],r[2],r[3])))
print(f'Wrote {len(rows)} component rows to {out}')
PY
