#!/usr/bin/env bash
set -euo pipefail
# -e: exit immediately if a command fails
# -u: treat unset variables as an error
# -o pipefail: fail if any command in a pipeline fails

# Ensure the script itself is executable (useful if invoked in CI/CD)
chmod +x ./scripts/authenticate.sh

# Capture the alias name passed as the first argument
# If not provided, show usage message and exit
alias_name="${1:?Usage: authenticate.sh <alias>}"

# Require the SFDX_AUTH_URL environment variable (must be set as a secret)
: "${SFDX_AUTH_URL:?SFDX_AUTH_URL secret is required}"

# Write the auth URL into a temporary file for CLI login
printf '%s' "$SFDX_AUTH_URL" > .sf-auth-url.txt

# Restrict file permissions so only the current user can read/write
chmod 600 .sf-auth-url.txt

# Log in to Salesforce org using the auth URL file
# Assign the provided alias and set it as the default org
sf org login sfdx-url --sfdx-url-file .sf-auth-url.txt --alias "$alias_name" --set-default

# Display org details to confirm successful authentication
sf org display --target-org "$alias_name"
