#!/usr/bin/env bash
set -euo pipefail

WAYBAR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
THEMES_DIR="$WAYBAR_DIR/Configs-way"

if ! command -v rofi >/dev/null 2>&1; then
    echo "Error: rofi no esta instalado." >&2
    exit 1
fi

mapfile -t THEMES < <(find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
if [[ ${#THEMES[@]} -eq 0 ]]; then
    echo "Error: no hay temas en $THEMES_DIR" >&2
    exit 1
fi

SELECTED_THEME="$(printf '%s\n' "${THEMES[@]}" | rofi -dmenu -i -p 'Waybar theme')"
[[ -z "${SELECTED_THEME:-}" ]] && exit 0

THEME_PATH="$THEMES_DIR/$SELECTED_THEME"
[[ -d "$THEME_PATH" ]] || { echo "Tema invalido: $SELECTED_THEME" >&2; exit 1; }

BACKUP_DIR="$WAYBAR_DIR/.theme-backups/$(date +%Y%m%d-%H%M%S)-$SELECTED_THEME"
mkdir -p "$BACKUP_DIR"

for f in config.jsonc style.css; do
    [[ -f "$WAYBAR_DIR/$f" ]] && cp -f "$WAYBAR_DIR/$f" "$BACKUP_DIR/$f"
    [[ -f "$THEME_PATH/$f" ]] && cp -f "$THEME_PATH/$f" "$WAYBAR_DIR/$f"
done

if [[ -d "$THEME_PATH/modules" ]]; then
    [[ -d "$WAYBAR_DIR/modules" ]] && cp -a "$WAYBAR_DIR/modules" "$BACKUP_DIR/modules"
    rm -rf "$WAYBAR_DIR/modules"
    cp -a "$THEME_PATH/modules" "$WAYBAR_DIR/modules"
fi

# Fusiona scripts del tema sin borrar scripts existentes (evita perder theme_selector.sh).
if [[ -d "$THEME_PATH/scripts" ]]; then
    [[ -d "$WAYBAR_DIR/scripts" ]] || mkdir -p "$WAYBAR_DIR/scripts"
    cp -a "$THEME_PATH/scripts/." "$WAYBAR_DIR/scripts/"
fi

pkill waybar >/dev/null 2>&1 || true
nohup waybar >/dev/null 2>&1 &

command -v notify-send >/dev/null 2>&1 && notify-send "Waybar" "Tema aplicado: $SELECTED_THEME"
echo "Tema aplicado: $SELECTED_THEME"
