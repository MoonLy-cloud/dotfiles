#!/usr/bin/env bash
set -euo pipefail

WAYBAR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
THEMES_DIR="$WAYBAR_DIR/Configs-way"

if ! command -v rofi >/dev/null 2>&1; then
    echo "Error: rofi no esta instalado." >&2
    exit 1
fi

if [[ ! -d "$THEMES_DIR" ]]; then
    echo "Error: no existe la carpeta de temas en $THEMES_DIR" >&2
    exit 1
fi

mapfile -t THEMES < <(find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)

if [[ ${#THEMES[@]} -eq 0 ]]; then
    echo "Error: no hay temas disponibles en $THEMES_DIR" >&2
    exit 1
fi

SELECTED_THEME="$(printf '%s\n' "${THEMES[@]}" | rofi -dmenu -i -p 'Waybar theme')"

if [[ -z "${SELECTED_THEME:-}" ]]; then
    exit 0
fi

THEME_PATH="$THEMES_DIR/$SELECTED_THEME"
if [[ ! -d "$THEME_PATH" ]]; then
    echo "Error: tema invalido: $SELECTED_THEME" >&2
    exit 1
fi

# Backup rapido por si quieres volver atras.
BACKUP_DIR="$WAYBAR_DIR/.theme-backups/$(date +%Y%m%d-%H%M%S)-$SELECTED_THEME"
mkdir -p "$BACKUP_DIR"

for f in config.jsonc style.css; do
    if [[ -f "$WAYBAR_DIR/$f" ]]; then
        cp -f "$WAYBAR_DIR/$f" "$BACKUP_DIR/$f"
    fi
    if [[ -f "$THEME_PATH/$f" ]]; then
        cp -f "$THEME_PATH/$f" "$WAYBAR_DIR/$f"
    fi
done

if [[ -d "$THEME_PATH/modules" ]]; then
    if [[ -d "$WAYBAR_DIR/modules" ]]; then
        cp -a "$WAYBAR_DIR/modules" "$BACKUP_DIR/modules"
    fi
    rm -rf "$WAYBAR_DIR/modules"
    cp -a "$THEME_PATH/modules" "$WAYBAR_DIR/modules"
fi

if [[ -d "$THEME_PATH/scripts" ]]; then
    if [[ -d "$WAYBAR_DIR/scripts" ]]; then
        cp -a "$WAYBAR_DIR/scripts" "$BACKUP_DIR/scripts"
    fi
    rm -rf "$WAYBAR_DIR/scripts"
    cp -a "$THEME_PATH/scripts" "$WAYBAR_DIR/scripts"
fi

pkill waybar >/dev/null 2>&1 || true
nohup waybar >/dev/null 2>&1 &

if command -v notify-send >/dev/null 2>&1; then
    notify-send "Waybar" "Tema aplicado: $SELECTED_THEME"
fi

echo "Tema aplicado: $SELECTED_THEME"
