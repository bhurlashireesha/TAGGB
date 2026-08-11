#!/usr/bin/env bash
set -euo pipefail
# -e: exit immediately if a command fails
# -u: treat unset variables as an error
# -o pipefail: fail if any command in a pipeline fails

# Capture required arguments
mode="${1:?mode required}"          # Either 'validate' or 'deploy'
delta_dir="${2:?delta required}"    # Directory containing delta package
org="${3:?org required}"            # Target Salesforce org alias
level="${4:?test level required}"   # Apex test level (RunLocalTests, RunAllTestsInOrg, RunSpecifiedTests, etc.)
tests="${5:-}"                      # Optional list of test classes (used if RunSpecifiedTests)

# Paths to package and destructive changes manifests
pkg="$delta_dir/package/package.xml"
destructive="$delta_dir/destructiveChanges/destructiveChanges.xml"

# Helper function: check if XML file exists and has <members>
has() { [[ -s "$1" ]] && grep -q '<members>' "$1"; }

# Flags for package and destructive changes
hp=false; hd=false
has "$pkg" && hp=true
has "$destructive" && hd=true

# Exit early if no deployable metadata changes found
if [[ "$hp" == false && "$hd" == false ]]; then
  echo "No deployable metadata changes."
  echo 'has_changes=false' >> "${GITHUB_OUTPUT:-/dev/null}"
  exit 0
fi

# Mark that changes exist for downstream steps
echo 'has_changes=true' >> "$GITHUB_OUTPUT" 2>/dev/null || true

# Build common CLI arguments
args=(--target-org "$org" --wait 120 --test-level "$level" --json)
[[ "$hp" == true ]] && args+=(--manifest "$pkg")
[[ "$hd" == true ]] && args+=(--post-destructive-changes "$destructive")

# Handle RunSpecifiedTests case
if [[ "$level" == RunSpecifiedTests ]]; then
  # Fail if no test classes provided
  [[ -n "$tests" ]] || { echo 'RunSpecifiedTests selected but no tests supplied'; exit 2; }
  # Split test class list into array and add to args
  read -r -a test_array <<< "$tests"
  args+=(--tests "${test_array[@]}")
fi

# Execute deployment or validation based on mode
if [[ "$mode" == validate ]]; then
  # Validation only (no actual deploy)
  sf project deploy validate "${args[@]}" | tee deployment-result.json
elif [[ "$mode" == deploy ]]; then
  # Real deployment
  sf project deploy start "${args[@]}" | tee deployment-result.json
else
  # Unsupported mode provided
  echo "Unsupported mode: $mode"
  exit 2
fi
