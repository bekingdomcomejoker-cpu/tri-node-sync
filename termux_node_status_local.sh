#!/data/data/com.termux/files/usr/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SSH_CONFIG="$ROOT/mikrotik_ssh_config"

printf '=== LOCAL-ONLY TRI-NODE STATUS ===\n'
printf 'mode=Redmi + MikroTik; Render disabled\n'
printf 'redmi-service=\n'
curl --silent --show-error --max-time 5 http://127.0.0.1:5000/api/health || true
printf '\n'
printf 'mikrotik-ssh=\n'
ssh -F "$SSH_CONFIG" -o BatchMode=yes -o ConnectTimeout=10 mikrotik-rb951 '/system identity print' || true
printf 'git-head=\n'
git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || true
