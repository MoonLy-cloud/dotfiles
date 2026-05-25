#!/bin/bash

# Buscar los paths reales de los LEDs (varían según teclado/kernel)
CAPS_LED_PATH=$(ls /sys/class/leds/ | grep -i "capslock" | head -1)
NUM_LED_PATH=$(ls /sys/class/leds/ | grep -i "numlock" | head -1)

if [ -z "$CAPS_LED_PATH" ] || [ -z "$NUM_LED_PATH" ]; then
    echo "Error: No se encontraron LEDs en /sys/class/leds/"
    echo "LEDs disponibles:"
    ls /sys/class/leds/
    exit 1
fi

read_led() {
    cat "/sys/class/leds/$1/brightness" 2>/dev/null
}

send_notification() {
    local label="$1"
    local state="$2"   # "1" = on, "0" = off
    local icon="$3"

    if [ "$state" = "1" ]; then
        notify-send -u low -t 1500 "$icon $label" "Activado"
    else
        notify-send -u low -t 1500 "$icon $label" "Desactivado"
    fi
}

LAST_CAPS=$(read_led "$CAPS_LED_PATH")
LAST_NUM=$(read_led "$NUM_LED_PATH")

while true; do
    CURRENT_CAPS=$(read_led "$CAPS_LED_PATH")
    CURRENT_NUM=$(read_led "$NUM_LED_PATH")

    if [ "$CURRENT_CAPS" != "$LAST_CAPS" ]; then
        send_notification "Mayúsculas" "$CURRENT_CAPS" "󰪛"
        LAST_CAPS=$CURRENT_CAPS
    fi

    if [ "$CURRENT_NUM" != "$LAST_NUM" ]; then
        send_notification "Bloqueo Numérico" "$CURRENT_NUM" "󰎠"
        LAST_NUM=$CURRENT_NUM
    fi

    sleep 0.2
done