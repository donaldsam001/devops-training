#!/usr/bin/env bash
set -e

EXPECTED_DOMAIN="$1"

if [ -z "$EXPECTED_DOMAIN" ]; then
    echo "Usage: $0 <expected-domain>"
    exit 2
fi

# check inside git repo
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not a git repository."
    exit 2
fi

NAME=$(git config user.name || true)
EMAIL=$(git config user.email || true)
REMOTE_URL=$(git config --get remote.origin.url || echo "No remote configure")

echo "=== Git Identity Check ==="
echo "User Name  : ${NAME:-[Not Set]}"
echo "User Email : ${EMAIL:-[Not Set]}"
echo "Remote URL : ${REMOTE_URL}"

if [ -z "$EMAIL" ]; then
    echo "Error: user.email is not set."
    exit 1
fi

EMAIL_DOMAIN="${EMAIL##*@}"

if [ "$EMAIL_DOMAIN" != "$EXPECTED_DOMAIN" ]; then
    echo "WARNING: Email domain '${EMAIL_DOMAIN}' does not match expected domain '${EXPECTED_DOMAIN}'!"
    exit 1
else
    echo "OK: Email matches domain '${EXPECTED_DOMAIN}'."
    exit 0
fi