#!/usr/bin/env bash
set -euo pipefail
# -e: exit immediately if a command fails
# -u: treat unset variables as an error
# -o pipefail: fail if any command in a pipeline fails

# Ensure this script itself is executable (useful in CI/CD pipelines)
chmod +x "$0"

# Capture required arguments
from_ref="${1:?Usage: generate-delta.sh <from> <to> [output-dir]}"  # Baseline commit/tag
to_ref="${2:?Usage: generate-delta.sh <from> <to> [output-dir]}"    # Target commit/tag
out_dir="${3:-delta}"                                               # Output directory (default: delta)

# Verify that both commit references exist in the repository
git rev-parse --verify "${from_ref}^{commit}" >/dev/null
git rev-parse --verify "${to_ref}^{commit}" >/dev/null

# Clean up any existing output directory and recreate it
rm -rf "$out_dir"
mkdir -p "$out_dir"

# Generate delta package using sfdx-git-delta plugin
# This creates package.xml and destructiveChanges.xml based on differences between commits
sf sgd source delta --from "$from_ref" --to "$to_ref" --output-dir "$out_dir"

# Print a list of changed files for visibility/logging
echo "Changed files:"
git diff --name-status "$from_ref" "$to_ref"
