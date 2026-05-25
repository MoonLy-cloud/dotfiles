#!/usr/bin/env bash

# Estado inicial
FILES_CURRENT=$(lsusb | sort)

while true; do
    # Esperar un poco para no saturar el CPU
    sleep 2

    # Nuevo estado
    FILES_NEW=$(lsusb | sort)

    # 1. DETECTAR CONEXIONES (Líneas que están en NEW pero no en CURRENT)
    ADDED=$(comm -13 <(echo "$FILES_CURRENT") <(echo "$FILES_NEW"))
    
    if [ -n "$ADDED" ]; then
        # Limpiar el nombre (quitamos el Bus 00X Device 00X: ID...)
        NAME=$(echo "$ADDED" | cut -d ' ' -f 7-)
        notify-send "Dispositivo Conectado" "  $NAME" -i "drive-removable-media-usb" -u normal
    fi

    # 2. DETECTAR DESCONEXIONES (Líneas que estaban en CURRENT pero no en NEW)
    REMOVED=$(comm -23 <(echo "$FILES_CURRENT") <(echo "$FILES_NEW"))
    
    if [ -n "$REMOVED" ]; then
        NAME=$(echo "$REMOVED" | cut -d ' ' -f 7-)
        notify-send "Dispositivo Desconectado" "  $NAME" -i "drive-removable-media-usb" -u low
    fi

    # Actualizar estado
    if [ "$FILES_CURRENT" != "$FILES_NEW" ]; then
        FILES_CURRENT="$FILES_NEW"
    fi
done
