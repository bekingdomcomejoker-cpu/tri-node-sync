#!/data/data/com.termux/files/usr/bin/sh
set -eu
ROOT="${TRI_NODE_ROOT:-$HOME/omega-federation-tri-node}"
for dir in logs data sync backups scripts mikrotik/usb-ledger mikrotik/logs github render; do
  mkdir -p "$ROOT/$dir"
done
printf 'Tri-node Termux workspace ready: %s\n' "$ROOT"
printf 'No credentials, remote synchronization, or schedules were configured.\n'
