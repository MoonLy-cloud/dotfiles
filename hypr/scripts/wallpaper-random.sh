#!/usr/bin/env bash

# --- CONFIGURACIÓN ---
# ⚠️ Asegúrate de que esta carpeta exista y tenga imágenes
DIR="$HOME/Wallpapers" 
FPS=60
STEP=90 

# 1. Seleccionar imagen al azar
# (Usamos nullglob para evitar errores si no hay gifs, etc)
shopt -s nullglob
PICS=($DIR/*.jpg $DIR/*.png $DIR/*.jpeg $DIR/*.gif)
RANDOMPICS=${PICS[ $RANDOM % ${#PICS[@]} ]}

if [ -z "$RANDOMPICS" ]; then
    echo "Error: No se encontraron imágenes en $DIR"
    exit 1
fi

# 2. Definir transiciones
TRANSITIONS=("grow" "outer" "wave" "wipe" "any")
SELECTED_TRANSITION=${TRANSITIONS[ $RANDOM % ${#TRANSITIONS[@]} ]}

# 3. Posición y Ángulo Random
POS_X="0.$((RANDOM % 9 + 1))"
POS_Y="0.$((RANDOM % 9 + 1))"
ANGLE=$((RANDOM % 360))

echo "Imagen: $RANDOMPICS | Efecto: $SELECTED_TRANSITION"

# 4. EJECUTAR SWWW (Cambio visual)
awww img "$RANDOMPICS" \
    --transition-type "$SELECTED_TRANSITION" \
    --transition-pos "$POS_X,$POS_Y" \
    --transition-angle "$ANGLE" \
    --transition-fps $FPS \
    --transition-step $STEP \
    --transition-bezier 0.65,0,0.35,1 

# ----------------------------------------------------- 
# 🎨 AQUÍ EMPIEZA LA MAGIA DE PYWAL (Colores)
# ----------------------------------------------------- 

# A. Generar paleta de colores basada en la imagen elegida ($RANDOMPICS)
# -n: No cambiar fondo (swww ya lo hizo)
# -s: Silencioso (no limpiar terminal)
# -t: Generar tema para terminales
wal -i "$RANDOMPICS" -n -s -t

# B. Recargar Waybar para que lea los nuevos colores
# (Esperamos un poco para asegurar que wal terminó de escribir el archivo)
sleep 0.5
killall waybar
waybar &

# C. Recargar SwayNC (Notificaciones)
swaync-client -rs

# D. (Opcional) Recargar Hyprland si usas bordes dinámicos
hyprctl reload