#!/usr/bin/env bash

# Leer historial de dunst, parsear con jq y mostrar en rofi
# Nota: .data[0] contiene el historial. Iteramos sobre él.

NOTIFICATIONS=$(dunstctl history | jq -r '.data[0][] | "<b>[\(.appname.data)]</b> \(.summary.data) \n <span size=\"small\" color=\"#a9b1d6\">\(.body.data)</span>\n"')

# Si no hay historial
if [ -z "$NOTIFICATIONS" ]; then
    rofi -e "No hay notificaciones en el historial."
    exit 0
fi

# Mostrar en Rofi
# -markup-rows permite usar colores y negritas en la lista
# Cambia "~/.config/rofi/style.rasi" por "~/.config/rofi/notifications.rasi"
echo -e "$NOTIFICATIONS" | rofi -dmenu -i -markup-rows -p "" -theme ~/.config/rofi/notifications.rasi