#!/usr/bin/env bash
set -euo pipefail
# -e: exit immediately if a command fails
# -u: treat unset variables as an error
# -o pipefail: fail if any command in a pipeline fails

# Ensure the script itself is executable (useful in CI/CD pipelines)
chmod +x "$0"

# Capture required arguments
delta_dir="${1:?Usage: build-component-ledger.sh <delta-dir> <tag> <from> <to>}"  # Directory containing delta package
tag="${2:?tag required}"        # Release tag name
from_ref="${3:?from required}"  # Baseline commit/tag
to_ref="${4:?to required}"      # Target commit/tag

# Inline Python script to parse package.xml and destructiveChanges.xml
python3 - "$delta_dir" "$tag" "$from_ref" "$to_ref" <<'PY'
import csv, pathlib, sys, xml.etree.ElementTree as ET

# Read arguments passed from shell
root_dir, tag, from_ref, to_ref = sys.argv[1:]

rows=[]
# Iterate over deployable and deletable metadata manifests
for action, rel in [('deploy','package/package.xml'), ('delete','destructiveChanges/destructiveChanges.xml')]:
    p = pathlib.Path(root_dir) / rel
    if not p.exists():
        continue
    # Parse XML manifest
    root = ET.parse(p).getroot()
    ns = {'m':'http://soap.sforce.com/2006/04/metadata'}
    # Extract metadata types and members
    for t in root.findall('m:types', ns):
        name = t.findtext('m:name', default='', namespaces=ns)
        for member in t.findall('m:members', ns):
            rows.append([tag, action, name, member.text or '', from_ref, to_ref])

# Write results to component-version-map.csv
out = pathlib.Path(root_dir) / 'component-version-map.csv'
with out.open('w', newline='', encoding='utf-8') as f:
    w = csv.writer(f)
    # Header row
    w.writerow(['release_tag','action','metadata_type','component','from_revision','to_revision'])
    # Sort rows by action, type, and component for consistency
    w.writerows(sorted(rows, key=lambda r:(r[1], r[2], r[3])))

print(f'Wrote {len(rows)} component rows to {out}')
PY

# Ensure generated files are world-readable so GitHub Actions can upload them
chmod 644 "$delta_dir/component-version-map.csv"
chmod 644 "$delta_dir/package/package.xml"
