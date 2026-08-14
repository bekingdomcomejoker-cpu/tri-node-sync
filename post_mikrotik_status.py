#!/data/data/com.termux/files/usr/bin/python3
"""Collect read-only MikroTik status and post a valid JSON report to the Redmi-local API."""
import json
import os
import subprocess
import sys
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent
API_URL = os.environ.get("API_URL", "http://127.0.0.1:5000").rstrip("/")
SSH_CONFIG = ROOT / "mikrotik_ssh_config"


def ssh_read(router_command: str) -> str:
    command = [
        "ssh",
        "-F",
        str(SSH_CONFIG),
        "-o",
        "BatchMode=yes",
        "-o",
        "ConnectTimeout=10",
        "-o",
        "LogLevel=ERROR",
        "mikrotik-rb951",
        router_command,
    ]
    result = subprocess.run(command, text=True, capture_output=True, timeout=20)
    if result.returncode != 0:
        message = result.stderr.strip() or "MikroTik SSH command failed"
        raise RuntimeError(message)
    return result.stdout.strip()


def post_report(payload: dict) -> dict:
    request = urllib.request.Request(
        f"{API_URL}/api/mikrotik-report",
        data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
        headers={"Content-Type": "application/json", "Accept": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=15) as response:
        return json.loads(response.read().decode("utf-8"))


def main() -> int:
    try:
        identity = ssh_read("/system identity print")
        wireless = ssh_read("/interface wireless print")
        payload = {
            "status": "ONLINE",
            "detail": {"identity": identity, "wireless": wireless},
            "reported_at": datetime.now(timezone.utc).isoformat(),
        }
        response = post_report(payload)
    except (RuntimeError, OSError, urllib.error.URLError, json.JSONDecodeError) as exc:
        print(f"MikroTik report failed: {exc}", file=sys.stderr)
        return 1
    print(json.dumps(response, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
