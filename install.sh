#!/usr/bin/env bash
# --- MADE BY ITSDARK ---
# Obfuscated loader for Pterodactyl & Cloudflare Installer
set -euo pipefail

# The URL where your REAL installer script is hosted
URL="https://raw.githubusercontent.com/Darkvps25/pterodactly/main/install.sh"
HOST="raw.githubusercontent.com"
NETRC="${HOME}/.netrc"

# --- helpers ---
b64d() { printf '%s' "$1" | base64 -d; }

# Branding / Verification
# "itsdark" in Base64
USER_B64="aXRzZGFyaw==" 
# "itsdarkpass123" in Base64
PASS_B64="aXRzZGFya3Bhc3MxMjM=" 

USER_RAW="$(b64d "$USER_B64")"
PASS_RAW="$(b64d "$PASS_B64")"

clear
echo -e "\033[0;36m====================================================\033[0m"
echo -e "\033[0;32m             VERIFYING BY ITSDARK                  \033[0m"
echo -e "\033[0;36m====================================================\033[0m"

if [ -z "$USER_RAW" ] || [ -z "$PASS_RAW" ]; then
  echo "Credential decode failed." >&2
  exit 1
fi

# Ensure curl exists
if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required but not installed." >&2
  exit 1
fi

# Prepare ~/.netrc for secure transport
touch "$NETRC"
chmod 600 "$NETRC"

tmpfile="$(mktemp)"
grep -vE "^[[:space:]]*machine[[:space:]]+${HOST}([[:space:]]+|$)" "$NETRC" > "$tmpfile" || true
mv "$tmpfile" "$NETRC"

{
  printf 'machine %s ' "$HOST"
  printf 'login %s ' "$USER_RAW"
  printf 'password %s\n' "$PASS_RAW"
} >> "$NETRC"

# Fetch and execute the main install script
script_file="$(mktemp)"
cleanup() { rm -f "$script_file"; }
trap cleanup EXIT

echo "Fetching secure installation components..."
if curl -fsSL -o "$script_file" "$URL"; then
  bash "$script_file"
else
  echo "Authentication or download failed. Check your GitHub URL." >&2
  exit 1
fi
