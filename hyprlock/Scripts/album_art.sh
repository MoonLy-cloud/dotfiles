#!/usr/bin/env bash

# Rutas temporales para guardar la portada y la URL
COVER="/tmp/album_cover.png"
LAST_URL_FILE="/tmp/album_last_url"

# Obtenemos la URL de la portada desde playerctl
URL=$(playerctl metadata mpris:artUrl 2>/dev/null)

# Si no hay canción o no hay portada, limpiamos y salimos
if [ -z "$URL" ]; then
    echo ""
    exit 0
fi

# Leemos la última URL procesada
LAST_URL=$(cat "$LAST_URL_FILE" 2>/dev/null)

# Si la URL cambió, significa que es una canción nueva
if [ "$URL" != "$LAST_URL" ]; then
    # Si la URL viene de Spotify web/Brave (empieza con http)
    if [[ "$URL" == http* ]]; then
        curl -s "$URL" -o "$COVER"
    # Si viene de Spotify nativo o un reproductor local (empieza con file://)
    elif [[ "$URL" == file://* ]]; then
        cp "${URL#file://}" "$COVER"
    fi
    # Actualizamos el registro
    echo "$URL" > "$LAST_URL_FILE"
fi

# Le devolvemos a Hyprlock la ruta exacta de la imagen
echo "$COVER"
