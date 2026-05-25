#!/usr/bin/env bash

# --- CONFIGURACIÓN ---
# ID para que la notificación se reemplace a sí misma (efecto OSD)
TAG="sys-notify"

# Función para enviar notificación
send_notification() {
    ICON=$1
    TEXT=$2
    VALUE=$3
    
    # Barra de progreso simple
    # notify-send flags:
    # -h string:x-canonical-private-synchronous:$TAG -> IMPORTANTE: Esto hace que se actualice en lugar de acumularse
    # -h int:value:$VALUE -> Le dice a SwayNC el valor para la barra de progreso (si el tema lo soporta)
    notify-send -h string:x-canonical-private-synchronous:"$TAG" \
        -h int:value:"$VALUE" \
        -u low \
        -i "$ICON" \
        "$TEXT" \
        "Nivel: $VALUE%"
}

case $1 in
    # --- VOLUMEN ---
    vol_up)
        pamixer -i 5
        VOL=$(pamixer --get-volume)
        # Icono dinámico
        if [ "$VOL" -ge 50 ]; then ICON="audio-volume-high"; else ICON="audio-volume-medium"; fi
        send_notification "$ICON" "Volumen" "$VOL"
        ;;
    vol_down)
        pamixer -d 5
        VOL=$(pamixer --get-volume)
        if [ "$VOL" -le 20 ]; then ICON="audio-volume-low"; else ICON="audio-volume-medium"; fi
        send_notification "$ICON" "Volumen" "$VOL"
        ;;
    vol_mute)
        pamixer -t
        MUTE=$(pamixer --get-mute)
        if [ "$MUTE" == "true" ]; then
            notify-send -h string:x-canonical-private-synchronous:"$TAG" -u low -i "audio-volume-muted" "Silencio" "Audio desactivado"
        else
            notify-send -h string:x-canonical-private-synchronous:"$TAG" -u low -i "audio-volume-high" "Sonido" "Audio activado"
        fi
        ;;
    mic_mute)
        pamixer --default-source -t
        MUTE=$(pamixer --default-source --get-mute)
        if [ "$MUTE" == "true" ]; then
            notify-send -h string:x-canonical-private-synchronous:"$TAG" -u low -i "microphone-sensitivity-muted" "Micrófono" "Desactivado "
        else
            notify-send -h string:x-canonical-private-synchronous:"$TAG" -u low -i "microphone-sensitivity-high" "Micrófono" "Activado "
        fi
        ;;
    # --- BRILLO ---
    bri_up)
        brightnessctl set +5%
        # Obtener porcentaje actual (truco para limpiar la salida)
        BRI=$(brightnessctl -m | cut -d, -f4 | tr -d %)
        send_notification "display-brightness-high-symbolic" "Brillo" "$BRI"
        ;;
    bri_down)
        brightnessctl set 5%-
        BRI=$(brightnessctl -m | cut -d, -f4 | tr -d %)
        send_notification "display-brightness-low-symbolic" "Brillo" "$BRI"
        ;;
esac
