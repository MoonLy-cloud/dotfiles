#!/bin/bash

# Detectar batería (BAT0 o BAT1)
BAT=$(ls /sys/class/power_supply/ | grep BAT | head -n 1)

# Obtener capacidad y estado
CAPACITY=$(cat /sys/class/power_supply/$BAT/capacity)
STATUS=$(cat /sys/class/power_supply/$BAT/status)

# Icono por defecto
ICON=""

if [ "$STATUS" = "Charging" ]; then
    ICON=""
else
    if [ "$CAPACITY" -ge 90 ]; then ICON=""
    elif [ "$CAPACITY" -ge 60 ]; then ICON=""
    elif [ "$CAPACITY" -ge 40 ]; then ICON=""
    elif [ "$CAPACITY" -ge 10 ]; then ICON=""
    else ICON=""
    fi
fi

echo "$ICON  $CAPACITY%"
