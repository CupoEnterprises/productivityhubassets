#!/bin/bash
# Generate SHA-256 hash for the Recipe Manager web interface password
# Usage: ./generate-password-hash.sh
# Or:    ./generate-password-hash.sh mypassword

if [ -n "$1" ]; then
  PASSWORD="$1"
else
  echo -n "Enter password: "
  read -s PASSWORD
  echo
fi

HASH=$(printf '%s' "$PASSWORD" | shasum -a 256 | awk '{print $1}')

echo ""
echo "Password: $PASSWORD"
echo "SHA-256:  $HASH"
echo ""
echo "Paste this value into CONFIG.PASSWORD_HASH in index.html:"
echo "  PASSWORD_HASH: '$HASH'"
