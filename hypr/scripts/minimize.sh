#!/usr/bin/env bash

# Nombre del espacio especial
WORKSPACE="special:minimized"

if [ "$1" == "hide" ]; then
    # Mueve la ventana activa al silencio
    hyprctl dispatch movetoworkspacesilent "$WORKSPACE"

elif [ "$1" == "restore" ]; then
    # 1. Obtener lista (Tu formato original: Dirección  Clase: Título)
    WINDOWS=$(hyprctl clients -j | jq -r ".[] | select(.workspace.name == \"$WORKSPACE\") | \"\(.address)  \(.class): \(.title)\"")

    # Si no hay ventanas, salir
    if [ -z "$WINDOWS" ]; then
        notify-send -u low "Bolsillo Vacío" "No hay apps minimizadas"
        exit 0
    fi

    # 2. Mostrar menú Rofi
    # TRUCO: Usamos awk para leer la Clase ($2), quitarle los dos puntos, 
    # y agregar el código oculto \0icon\x1f al final de la línea.
    CHOICE=$(echo "$WINDOWS" | awk '{
        # $2 es "Spotify:", "Kitty:", etc.
        class = tolower($2);
        sub(/:/,"",class); # Quitamos los dos puntos
        
        # Imprimimos: Línea Original + Código de Icono
        printf "%s\0icon\x1f%s\n", $0, class
    }' | rofi -dmenu -i -show-icons -p "📦 Restaurar" -theme ~/.config/rofi/launcher.rasi)

    # 3. Restaurar selección
    if [ ! -z "$CHOICE" ]; then
        # Extraer la dirección (primera palabra)
        ADDR=$(echo "$CHOICE" | awk '{print $1}')
        
        # Traer de vuelta
        hyprctl dispatch movetoworkspace "+0,address:$ADDR"
        hyprctl dispatch focuswindow "address:$ADDR"
    fi
fi