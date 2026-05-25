#!/usr/bin/env bash

# Variable para recordar si ya te avisamos (evita spam)
NOTIFIED=0

while true; do
    # 1. Detectar automáticamente cuál es tu batería
    BAT=$(ls /sys/class/power_supply/ | grep BAT | head -n 1)

    # 2. Obtener datos actuales
    CAPACITY=$(cat /sys/class/power_supply/$BAT/capacity)
    STATUS=$(cat /sys/class/power_supply/$BAT/status)

    # 3. Lógica de Alerta (Solo si está descargando y es <= 20%)
    if [ "$STATUS" = "Discharging" ] && [ "$CAPACITY" -le 20 ]; then
        
        # Si NO hemos avisado todavía...
        if [ $NOTIFIED -eq 0 ]; then
            notify-send -u normal -i "battery-level-20-symbolic" "⚠️ Batería Baja ($CAPACITY%)" "Conecta el cargador o perderás tu trabajo."
            # Marcamos como avisado
            NOTIFIED=1
        fi

    # 4. Si la cargaste y subió de 20%, reseteamos la vigilancia
    elif [ "$CAPACITY" -gt 20 ]; then
        NOTIFIED=0
    fi

    # 5. Esperar 1 minuto antes de volver a revisar
    sleep 60
done
