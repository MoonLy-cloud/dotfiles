#!/usr/bin/env bash

# --- CONFIGURACIÓN ---
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
NAME="$(date +'%Y-%m-%d_%H-%M-%S.png')"
FILE="$DIR/$NAME"

if ! command -v hyprshot >/dev/null 2>&1; then
    notify-send -u critical "Error" "hyprshot no está instalado"
    exit 1
fi

if ! command -v grim >/dev/null 2>&1; then
    notify-send -u critical "Error" "grim no está instalado"
    exit 1
fi

# Iconos y Textos
opt_full="  Pantalla Completa"
opt_area="  Seleccionar Área"
opt_win="  Ventana Activa"
opt_delay="  Temporizador (3s)"

# 1. Mostrar menú Rofi (usando un tema específico si quieres, o el default)
# Nota: -lines 4 ajusta la altura al número de opciones
chosen=$(echo -e "$opt_full\n$opt_area\n$opt_win\n$opt_delay" | rofi -dmenu -i -p "📸 Captura" -theme ~/.config/rofi/screenshot.rasi)

# Si cancelas, salimos
if [ -z "$chosen" ]; then
    exit 0
fi

# --- FUNCIONES ---
notify_cmd() {
    notify-send -h string:x-canonical-private-synchronous:shot-notify \
        -u low -i "camera-photo-symbolic" "$1" "$2"
}

countdown() {
    for i in 3 2 1; do
        notify_cmd "Captura en $i..." "Prepara la pose"
        sleep 1
    done
    # Limpiar notificación antes de la foto
    notify_cmd "Sonrían..." " " 
    sleep 0.5
}

open_in_pinta() {
    if command -v pinta >/dev/null 2>&1; then
        nohup pinta "$FILE" >/dev/null 2>&1 &
    else
        notify-send -u normal "Pinta no encontrado" "Instala pinta para editar la captura automáticamente"
    fi
}

capture_success() {
    notify-send -i "$FILE" "Captura Guardada" "Archivo: $FILE"
    open_in_pinta
}

take_shot() {
    local animations_disabled=0
    if command -v hyprctl >/dev/null 2>&1; then
        if hyprctl keyword animations:enabled 0 >/dev/null 2>&1; then
            animations_disabled=1
        fi
    fi

    if hyprshot -o "$DIR" -f "$NAME" -s "$@"; then
        if [ "$animations_disabled" -eq 1 ]; then
            hyprctl keyword animations:enabled 1 >/dev/null 2>&1
        fi
        capture_success
        return 0
    else
        if [ "$animations_disabled" -eq 1 ]; then
            hyprctl keyword animations:enabled 1 >/dev/null 2>&1
        fi
        return 1
    fi
}

take_full() {
    # Usar grim como método principal para captura completa (evita pulsar/selección de hyprshot)
    local animations_disabled=0
    if command -v hyprctl >/dev/null 2>&1; then
        if hyprctl keyword animations:enabled 0 >/dev/null 2>&1; then
            animations_disabled=1
        fi
    fi

    if grim "$FILE" && wl-copy < "$FILE"; then
        if [ "$animations_disabled" -eq 1 ]; then
            hyprctl keyword animations:enabled 1 >/dev/null 2>&1
        fi
        capture_success
        return 0
    fi

    if [ "$animations_disabled" -eq 1 ]; then
        hyprctl keyword animations:enabled 1 >/dev/null 2>&1
    fi

    # Fallback a hyprshot si grim falla
    if take_shot -m active -m output || take_shot -m output; then
        return 0
    fi

    notify-send -u critical "Captura fallida" "No se pudo capturar pantalla completa"
    return 1
}

take_window_active() {
    if take_shot -m window -m active || take_shot -m active -m window; then
        return 0
    fi

    if command -v jq >/dev/null 2>&1; then
        local geom
        geom=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        if [ -n "$geom" ] && [ "$geom" != "null,null nullxnull" ]; then
            if grim -g "$geom" "$FILE" && wl-copy < "$FILE"; then
                capture_success
                return 0
            fi
        fi
    fi

    notify-send -u critical "Captura fallida" "No se pudo capturar la ventana activa"
    return 1
}

# --- LÓGICA ---
case $chosen in
    "$opt_full")
        sleep 0.5 # Pequeña espera para que se cierre Rofi
        take_full
        ;;
    "$opt_area")
        take_shot -m region -z || notify-send -u critical "Captura fallida" "No se pudo capturar el área"
        ;;
    "$opt_win")
        sleep 0.5
        take_window_active
        ;;
    "$opt_delay")
        countdown
        take_full
        ;;
esac