#!/usr/bin/env bash
set -euo pipefail

WAYBAR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
ROFI_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/rofi"
WAYBAR_THEMES_DIR="$WAYBAR_DIR/Configs-way"
ROFI_THEMES_DIR="$ROFI_DIR/Configs-rofi"

# Validar dependencias
if ! command -v rofi >/dev/null 2>&1; then
    echo "Error: rofi no esta instalado." >&2
    exit 1
fi

if [[ ! -d "$WAYBAR_THEMES_DIR" ]]; then
    echo "Error: no existe la carpeta de temas Waybar en $WAYBAR_THEMES_DIR" >&2
    exit 1
fi

# Obtener temas Waybar
mapfile -t WAYBAR_THEMES < <(find "$WAYBAR_THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)

if [[ ${#WAYBAR_THEMES[@]} -eq 0 ]]; then
    echo "Error: no hay temas Waybar disponibles en $WAYBAR_THEMES_DIR" >&2
    exit 1
fi

# Selector visual con tema personalizado
SELECTED_THEME="$(printf '%s\n' "${WAYBAR_THEMES[@]}" | rofi -config "$ROFI_DIR/theme-selector.rasi" -dmenu -i -p '󰄬 Theme')"

if [[ -z "${SELECTED_THEME:-}" ]]; then
    exit 0
fi

WAYBAR_THEME_PATH="$WAYBAR_THEMES_DIR/$SELECTED_THEME"
if [[ ! -d "$WAYBAR_THEME_PATH" ]]; then
    echo "Error: tema Waybar invalido: $SELECTED_THEME" >&2
    exit 1
fi

# ═══ APLICAR TEMA WAYBAR ═══
BACKUP_DIR="$WAYBAR_DIR/.theme-backups/$(date +%Y%m%d-%H%M%S)-$SELECTED_THEME"
mkdir -p "$BACKUP_DIR"

for f in config.jsonc style.css; do
    if [[ -f "$WAYBAR_DIR/$f" ]]; then
        cp -f "$WAYBAR_DIR/$f" "$BACKUP_DIR/$f"
    fi
    if [[ -f "$WAYBAR_THEME_PATH/$f" ]]; then
        cp -f "$WAYBAR_THEME_PATH/$f" "$WAYBAR_DIR/$f"
    fi
done

if [[ -d "$WAYBAR_THEME_PATH/modules" ]]; then
    if [[ -d "$WAYBAR_DIR/modules" ]]; then
        cp -a "$WAYBAR_DIR/modules" "$BACKUP_DIR/modules"
    fi
    rm -rf "$WAYBAR_DIR/modules"
    cp -a "$WAYBAR_THEME_PATH/modules" "$WAYBAR_DIR/modules"
fi

if [[ -d "$WAYBAR_THEME_PATH/scripts" ]]; then
    if [[ -d "$WAYBAR_DIR/scripts" ]]; then
        cp -a "$WAYBAR_DIR/scripts" "$BACKUP_DIR/scripts"
    fi
    rm -rf "$WAYBAR_DIR/scripts"
    cp -a "$WAYBAR_THEME_PATH/scripts" "$WAYBAR_DIR/scripts"
fi

# ═══ APLICAR TEMA ROFI (si existe con el mismo nombre) ═══
ROFI_THEME_PATH="$ROFI_THEMES_DIR/$SELECTED_THEME"
if [[ -d "$ROFI_THEME_PATH" ]]; then
    # Backup rofi
    ROFI_BACKUP_DIR="$ROFI_DIR/.theme-backups/$(date +%Y%m%d-%H%M%S)-$SELECTED_THEME"
    mkdir -p "$ROFI_BACKUP_DIR"
    
    for f in config.rasi style.rasi; do
        if [[ -f "$ROFI_DIR/$f" ]]; then
            cp -f "$ROFI_DIR/$f" "$ROFI_BACKUP_DIR/$f"
        fi
        if [[ -f "$ROFI_THEME_PATH/$f" ]]; then
            cp -f "$ROFI_THEME_PATH/$f" "$ROFI_DIR/$f"
        fi
    done
    
    # Copiar scripts de rofi si existen
    if [[ -d "$ROFI_THEME_PATH/scripts" ]]; then
        if [[ -d "$ROFI_DIR/scripts" ]]; then
            cp -a "$ROFI_DIR/scripts" "$ROFI_BACKUP_DIR/scripts"
        fi
        rm -rf "$ROFI_DIR/scripts"
        cp -a "$ROFI_THEME_PATH/scripts" "$ROFI_DIR/scripts"
    fi
fi

# Reiniciar Waybar
pkill waybar >/dev/null 2>&1 || true
nohup waybar >/dev/null 2>&1 &

# Notificación
if command -v notify-send >/dev/null 2>&1; then
    if [[ -d "$ROFI_THEME_PATH" ]]; then
        notify-send "🎨 Tema" "Waybar + Rofi: $SELECTED_THEME"
    else
        notify-send "🎨 Waybar" "Tema aplicado: $SELECTED_THEME"
    fi
fi

echo "✓ Tema aplicado: $SELECTED_THEME"
[[ -d "$ROFI_THEME_PATH" ]] && echo "✓ Rofi también actualizado"
