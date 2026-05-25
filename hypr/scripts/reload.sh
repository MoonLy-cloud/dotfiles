#!/usr/bin/env bash

# --- 1. MAGIA DE PYWAL ---
if [ -n "$1" ]; then
    wal -q -i "$1"
else
    wal -q -R
fi

# --- 2. RECARGAR HYPRLAND ---
hyprctl reload

# --- 3. REINICIAR WAYBAR (Versión Inmortal) ---
pkill waybar
sleep 0.5
setsid waybar > /dev/null 2>&1 &
swaync-client -rs > /dev/null 2>&1 &

# --- 5. AVISO FINAL ---
notify-send "🌸 Aesthetic Recargado" "Sistema Recargado" -i utilities-terminal