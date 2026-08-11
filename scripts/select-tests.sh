#!/usr/bin/env bash
set -euo pipefail
# -e: exit immediately if a command fails
# -u: treat unset variables as an error
# -o pipefail: fail if any command in a pipeline fails

# Capture required arguments
delta_dir="${1:?delta dir required}"   # Directory containing delta package
fallback="${2:-NoTestRun}"             # Fallback test level if no tests are found (default: NoTestRun)

# Find all Apex class files (*.cls) in the delta directory
# -print0 / xargs -0: handle filenames with spaces
# grep -ilE: search for test annotations (@isTest or testMethod) case-insensitively
# basename: strip directory path
# sed: remove .cls extension
# sort -u: unique sorted list
mapfile -t tests < <(
  find "$delta_dir" -type f -name '*.cls' -print0 2>/dev/null \
  | xargs -0 -r grep -ilE '@[[:space:]]*

\[Ii]s[Tt]est|testMethod' \
  | xargs -r -n1 basename \
  | sed 's/\.cls$//' \
  | sort -u
)

# Write detected test class names into a file for evidence
printf '%s\n' "${tests[@]:-}" | sed '/^$/d' > "$delta_dir/detected-tests.txt"

# If tests were found, set outputs for RunSpecifiedTests
if (( ${#tests[@]} > 0 )); then
  # Tell GitHub Actions that test_level is RunSpecifiedTests
  echo "test_level=RunSpecifiedTests" >> "$GITHUB_OUTPUT"
  # Join test names into a space-separated string
  printf -v joined '%s ' "${tests[@]}"
  echo "tests=${joined% }" >> "$GITHUB_OUTPUT"
else
  # If no tests found, fall back to the provided test level (default: NoTestRun)
  echo "test_level=$fallback" >> "$GITHUB_OUTPUT"
  echo "tests=" >> "$GITHUB_OUTPUT"
fi
