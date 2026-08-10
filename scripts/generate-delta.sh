#!/usr/bin/env bash
set -euo pipefail
from_ref="${1:?Usage: generate-delta.sh <from> <to> [output-dir]}"
to_ref="${2:?Usage: generate-delta.sh <from> <to> [output-dir]}"
out_dir="${3:-delta}"
git rev-parse --verify "${from_ref}^{commit}" >/dev/null
git rev-parse --verify "${to_ref}^{commit}" >/dev/null
rm -rf "$out_dir"
mkdir -p "$out_dir"
sf sgd source delta --from "$from_ref" --to "$to_ref" --output-dir "$out_dir"
echo "Changed files:"
git diff --name-status "$from_ref" "$to_ref"