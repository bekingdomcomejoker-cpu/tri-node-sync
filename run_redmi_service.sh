#!/data/data/com.termux/files/usr/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
RUNTIME="$ROOT/.runtime"
PID_FILE="$RUNTIME/redmi_service.pid"
LOG_FILE="$RUNTIME/redmi_service.log"
mkdir -p "$RUNTIME"
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo "Redmi local service already running with PID $(cat "$PID_FILE")"
else
  rm -f "$PID_FILE" "$LOG_FILE"
  HOST=127.0.0.1 PORT=5000 nohup python3 "$ROOT/redmi_render_service.py" >"$LOG_FILE" 2>&1 &
  echo $! >"$PID_FILE"
  sleep 2
fi
curl --silent --show-error --fail --max-time 10 http://127.0.0.1:5000/api/health
printf '\n'
