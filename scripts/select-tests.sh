#!/usr/bin/env bash
set -euo pipefail
delta_dir="${1:?delta dir required}"; fallback="${2:-NoTestRun}"
mapfile -t tests < <(find "$delta_dir" -type f -name '*.cls' -print0 2>/dev/null | xargs -0 -r grep -ilE '@[[:space:]]*\[Ii]s[Tt]est|testMethod' | xargs -r -n1 basename | sed 's/\.cls$//' | sort -u)
printf '%s\n' "${tests[@]:-}" | sed '/^$/d' > "$delta_dir/detected-tests.txt"
if (( ${#tests[@]} > 0 )); then
  echo "test_level=RunSpecifiedTests" >> "$GITHUB_OUTPUT"
  printf -v joined '%s ' "${tests[@]}"
  echo "tests=${joined% }" >> "$GITHUB_OUTPUT"
else
  echo "test_level=$fallback" >> "$GITHUB_OUTPUT"
  echo "tests=" >> "$GITHUB_OUTPUT"
fi