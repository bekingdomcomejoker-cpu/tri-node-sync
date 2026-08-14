#!/data/data/com.termux/files/usr/bin/sh
# Read-only MikroTik status collector for the local Redmi service.
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
exec python3 "$ROOT/post_mikrotik_status.py"
