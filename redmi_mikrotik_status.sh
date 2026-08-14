#!/data/data/com.termux/files/usr/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SSH_CONFIG="$ROOT/mikrotik_ssh_config"
API_URL="${API_URL:-http://127.0.0.1:5000}"

identity="$(ssh -F "$SSH_CONFIG" -o BatchMode=yes -o ConnectTimeout=10 mikrotik-rb951 '/system identity print' 2>&1)"
wireless="$(ssh -F "$SSH_CONFIG" -o BatchMode=yes -o ConnectTimeout=10 mikrotik-rb951 '/interface wireless print' 2>&1)"

payload=$(printf '{"status":"ONLINE","detail":"%s"}' "$(printf '%s | %s' "$identity" "$wireless" | tr '\n' ' ' | sed 's/"/\\"/g')")
printf '%s' "$payload" | curl --silent --show-error --max-time 10 \
  -H 'Content-Type: application/json' --data-binary @- "$API_URL/api/mikrotik-report"
printf '\n'
