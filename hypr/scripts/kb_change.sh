#!/bin/bash

# 1. Obtener el nombre del layout actual del teclado principal
# Buscamos el teclado que realmente tiene layouts definidos
LAYOUT=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')

# 2. Lógica de cambio forzado
if [[ "$LAYOUT" == *"Spanish"* ]] || [[ "$LAYOUT" == *"Latam"* ]]; then
    # Si detecta español, cambia a Inglés (índice 1)
    hyprctl switchxkblayout all 1
    notify-send -u low -t 1500 "⌨️ Teclado" "Cambiado a: English (US)"
else
    # Si no, asume que está en inglés y cambia a Español (índice 0)
    hyprctl switchxkblayout all 0
    notify-send -u low -t 1500 "⌨️ Teclado" "Cambiado a: Español (Latam)"
fi