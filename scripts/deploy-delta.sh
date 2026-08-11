#!/usr/bin/env bash
set -euo pipefail
mode="${1:?mode required}"; delta_dir="${2:?delta required}"; org="${3:?org required}"; level="${4:?test level required}"; tests="${5:-}"
pkg="$delta_dir/package/package.xml"; destructive="$delta_dir/destructiveChanges/destructiveChanges.xml"
has() { [[ -s "$1" ]] && grep -q '<members>' "$1"; }
hp=false; hd=false; has "$pkg" && hp=true; has "$destructive" && hd=true
if [[ "$hp" == false && "$hd" == false ]]; then echo "No deployable metadata changes."; echo 'has_changes=false' >> "${GITHUB_OUTPUT:-/dev/null}"; exit 0; fi
echo 'has_changes=true' >> "$GITHUB_OUTPUT" 2>/dev/null || true
args=(--target-org "$org" --wait 120 --test-level "$level" --json)
[[ "$hp" == true ]] && args+=(--manifest "$pkg")
[[ "$hd" == true ]] && args+=(--post-destructive-changes "$destructive")
if [[ "$level" == RunSpecifiedTests ]]; then
  [[ -n "$tests" ]] || { echo 'RunSpecifiedTests selected but no tests supplied'; exit 2; }
  read -r -a test_array <<< "$tests"
  args+=(--tests "${test_array[@]}")
fi
if [[ "$mode" == validate ]]; then sf project deploy validate "${args[@]}" | tee deployment-result.json
elif [[ "$mode" == deploy ]]; then sf project deploy start "${args[@]}" | tee deployment-result.json
else echo "Unsupported mode: $mode"; exit 2; fi