#!/usr/bin/env bash
set -euo pipefail
alias_name="${1:?Usage: authenticate.sh <alias>}"
: "${SFDX_AUTH_URL:?SFDX_AUTH_URL secret is required}"
printf '%s' "$SFDX_AUTH_URL" > .sf-auth-url.txt
chmod 600 .sf-auth-url.txt
sf org login sfdx-url --sfdx-url-file .sf-auth-url.txt --alias "$alias_name" --set-default
sf org display --target-org "$alias_name"