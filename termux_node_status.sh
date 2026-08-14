#!/data/data/com.termux/files/usr/bin/sh
set -eu
RENDER_URL="${RENDER_URL:-https://omega-federation.onrender.com}"
printf '=== TRI-NODE TERMUX STATUS ===\n'
printf 'workspace='
printf '%s\n' "${TRI_NODE_ROOT:-$HOME/omega-federation-tri-node}"
printf 'github='
git -C "$(dirname "$0")" ls-remote origin HEAD 2>&1 || true
printf 'render-health='
curl --silent --show-error --max-time 10 --output /dev/null --write-out 'HTTP %{http_code}\n' "$RENDER_URL/api/health" 2>&1 || true
printf 'scheduler='
command -v crontab 2>/dev/null || echo 'not-installed'
printf 'mikrotik-auth='
test -s "$HOME/.omega-federation/mikrotik-password" && echo 'password-file-present' || echo 'password-file-absent'
