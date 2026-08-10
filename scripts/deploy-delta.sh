#!/usr/bin/env bash
set -euo pipefail
mode="${1:?Usage: deploy-delta.sh <validate|deploy> <delta-dir> <org-alias> <test-level>}"
delta_dir="${2:?delta-dir required}"
org_alias="${3:?org alias required}"
test_level="${4:-RunLocalTests}"
package_xml="$delta_dir/package/package.xml"
destructive_xml="$delta_dir/destructiveChanges/destructiveChanges.xml"
xml_has_members() {
    local file="$1"
    [[ -s "$file" ]] && grep -q '<members>' "$file"
}
has_package=false
has_destructive=false
xml_has_members "$package_xml" && has_package=true
xml_has_members "$destructive_xml" && has_destructive=true
if [[ "$has_package" == false && "$has_destructive" == false ]]; then
    echo "No deployable metadata changes detected."
    echo "has_changes=false" >> "${GITHUB_OUTPUT:-/dev/null}"
    exit 0
fi
echo "has_changes=true" >> "${GITHUB_OUTPUT:-/dev/null}"
args=(--target-org "$org_alias" --wait 60 --test-level "$test_level" --json)
[[ "$has_package" == true ]] && args+=(--manifest "$package_xml")
[[ "$has_destructive" == true ]] && args+=(--post-destructive-changes "$destructive_xml")
if [[ "$mode" == validate ]]; then
    sf project deploy validate "${args[@]}" | tee deployment-result.json
elif [[ "$mode" == deploy ]]; then
    sf project deploy start "${args[@]}" | tee deployment-result.json
else
    echo "Unsupported mode: $mode" >&2
    exit 2
fi
