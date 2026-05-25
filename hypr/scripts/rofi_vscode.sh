#!/usr/bin/env bash

# 1. Función para agregar iconos a la lista
add_icons() {
    while read -r line; do
        [ -z "$line" ] && continue
        REAL_PATH="${line/#\~/$HOME}"
        if [ -d "$REAL_PATH" ]; then
            echo "📁 $line"
        else
            echo "📄 $line"
        fi
    done
}

# 2. Búsqueda de carpetas y archivos (ajusta las rutas si es necesario)
LISTA_RAW=$(find ~/Documents ~/Projects ~/Downloads ~/.config -maxdepth 3 \
    \( -name ".git" -o -name ".cache" -o -name "node_modules" \) -prune \
    -o \( -type d -o -name "*.py" -o -name "*.sh" -o -name "*.jsonc" -o -name "*.conf" -o -name ".zshrc" \) -print 2>/dev/null \
    | sort | sed "s|^$HOME|~|")

# 3. Menú Principal
MENU=" Crear nuevo proyecto...\n$(echo "$LISTA_RAW" | add_icons)"

TARGET_CON_ICONO=$(echo -e "$MENU" | rofi -dmenu -i -p "󰨞 Abrir:" -theme ~/.config/rofi/launcher.rasi)

# Salir si se presiona ESC
[ -z "$TARGET_CON_ICONO" ] && exit 0

# --- EL TRUCO DE INGENIERÍA: LIMPIAR EL ICONO ---
# Usamos 'cut' para eliminar el emoji y el espacio (los primeros 3 caracteres)
# 📁 + espacio + ruta = 3 caracteres iniciales
TARGET_LIMPIO=$(echo "$TARGET_CON_ICONO" | cut -d' ' -f2-)
REAL_PATH="${TARGET_LIMPIO/#\~/$HOME}"

# 4. Lógica de ejecución
if [ "$TARGET_CON_ICONO" = " Crear nuevo proyecto..." ]; then
    NEW_DIR=$(rofi -dmenu -i -p "📁 Nombre de carpeta:" -theme ~/.config/rofi/launcher.rasi)
    if [ -n "$NEW_DIR" ]; then
        REAL_NEW="${NEW_DIR/#\~/$HOME}"
        mkdir -p "$REAL_NEW"
        code -n "$REAL_NEW"
    fi
else
    # Verificamos si la ruta limpia existe antes de abrir
    if [ -e "$REAL_PATH" ]; then
        # Enviamos notificación para saber que sí detectó el click
        notify-send "VS Code" "Abriendo: $TARGET_LIMPIO" -i vscode -t 1500
        code -n "$REAL_PATH"
    else
        notify-send "Error" "No se encontró: $TARGET_LIMPIO" -i error
    fi
fi