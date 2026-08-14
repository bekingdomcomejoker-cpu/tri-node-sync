#!/usr/bin/env python3
"""Local-only Redmi service for the MikroTik/Redmi deployment."""
from __future__ import annotations

import os
from datetime import datetime, timezone
from typing import Any

from flask import Flask, jsonify, request

app = Flask(__name__)


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


STATE: dict[str, Any] = {
    "deployment": "redmi-mikrotik-local-only",
    "render_enabled": False,
    "started_at": now(),
    "nodes": {
        "redmi": {"status": "ONLINE", "last_seen": now(), "role": "local-service"},
        "mikrotik": {"status": "UNKNOWN", "last_seen": None, "role": "network-node"},
    },
}


@app.get("/")
def index():
    return jsonify(
        {
            "service": "omega-federation-local",
            "deployment": STATE["deployment"],
            "endpoints": ["/api/health", "/api/status", "/api/mikrotik-report"],
        }
    )


@app.get("/api/health")
def health():
    STATE["nodes"]["redmi"]["last_seen"] = now()
    return jsonify({"status": "healthy", "node": "Redmi", "timestamp": now()})


@app.get("/api/status")
def status():
    STATE["nodes"]["redmi"]["last_seen"] = now()
    return jsonify({"status": "operational", "timestamp": now(), **STATE})


@app.post("/api/mikrotik-report")
def mikrotik_report():
    payload = request.get_json(silent=True) or {}
    node = STATE["nodes"]["mikrotik"]
    node["status"] = payload.get("status", "ONLINE")
    node["last_seen"] = now()
    node["detail"] = payload.get("detail", "SSH check succeeded")
    return jsonify({"status": "received", "timestamp": now()})


if __name__ == "__main__":
    host = os.getenv("HOST", "127.0.0.1")
    port = int(os.getenv("PORT", "5000"))
    app.run(host=host, port=port, debug=False)
