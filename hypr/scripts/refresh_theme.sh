#!/usr/bin/env bash

# Recibimos la ruta de la imagen desde Waypaper como argumento $1
IMG="$1"

# 1. Generar colores con Pywal
# -n: No cambiar fondo (Waypaper ya lo hizo)
# -s: Silencioso
# -t: Tema para terminales
wal -i "$IMG" -n -s -t

# 2. Copiar colores a carpetas donde otros programas los buscan (Opcional pero recomendado)
# cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/colors.css

# 3. Reiniciar Waybar
killall waybar
waybar &

# 4. Recargar notificaciones (SwayNC)
swaync-client -rs