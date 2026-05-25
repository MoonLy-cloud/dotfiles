#!/usr/bin/env bash
set -euo pipefail

if ! command -v dunstctl >/dev/null 2>&1; then
    printf '{"text":"󰂚", "tooltip":"dunstctl no instalado", "class":"disabled"}\n'
    exit 0
fi

paused="$(dunstctl is-paused 2>/dev/null || echo false)"
if [[ "$paused" == "true" ]]; then
    printf '{"text":"󰂛", "tooltip":"Notificaciones pausadas", "class":"paused"}\n'
else
    printf '{"text":"󰂚", "tooltip":"Notificaciones activas", "class":"active"}\n'
fi
