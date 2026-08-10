#!/usr/bin/env bash
set -euo pipefail

# Ensure the script itself is executable
chmod +x ./scripts/authenticate.sh

alias_name="${1:?Usage: authenticate.sh <alias>}"

# Select the right secret based on alias
case "$alias_name" in
  SIT)
    AUTH_URL="${SFDX_AUTH_URL:?SFDX_AUTH_URL secret is required for SIT}"
    ;;
  INT)
    AUTH_URL="${INT_SFDX_AUTH_URL:?INT_SFDX_AUTH_URL secret is required for INT}"
    ;;
  *)
    echo "❌ Unknown org alias: $alias_name"
    exit 1
    ;;
esac

# Write to temp file with safe permissions
printf '%s' "$AUTH_URL" > .sf-auth-url.txt
chmod 600 .sf-auth-url.txt

# Authenticate and set alias as default
sf org login sfdx-url --sfdx-url-file .sf-auth-url.txt --alias "$alias_name" --set-default
sf org display --target-org "$alias_name"
