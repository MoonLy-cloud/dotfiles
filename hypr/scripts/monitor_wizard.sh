#!/usr/bin/env bash

# --- 1. CONFIGURACIÓN E IDENTIFICACIÓN ---
# Detectamos el monitor interno por ID 0 (lo más seguro en laptops)
INTERNAL_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.id == 0) | .name')
if [ -z "$INTERNAL_MONITOR" ] || [ "$INTERNAL_MONITOR" == "null" ]; then
    INTERNAL_MONITOR="eDP-1"
fi

# Tu regla de oro para los 144Hz
INTERNAL_RULE="1920x1200@144"

# --- 2. SELECCIÓN DE MONITOR EXTERNO ---
# Listamos solo los que no son el interno
TARGET=$(hyprctl monitors all -j | jq -r --arg main "$INTERNAL_MONITOR" '.[] | select(.name != $main) | .name' | rofi -dmenu -p "🖥️ Monitor Detectado" -theme ~/.config/rofi/launcher.rasi)

if [ -z "$TARGET" ]; then exit 0; fi

# --- 3. MENÚ DE ACCIONES ---
ACTION=$(echo -e "Extender Derecha\nExtender Izquierda\nEspejo (Mirror)\nSolo Externo\nApagar Externo" | rofi -dmenu -p "⚙️ Configuración" -theme ~/.config/rofi/launcher.rasi)

if [ -z "$ACTION" ]; then exit 0; fi

case "$ACTION" in
    "Extender Derecha")
        HYPR_CMD="keyword monitor $INTERNAL_MONITOR,$INTERNAL_RULE,0x0,1; keyword monitor $TARGET,preferred,auto,1"
        MSG="Extendiendo pantalla a la derecha"
        ;;
    "Extender Izquierda")
        # El externo se vuelve el origen 0x0
        HYPR_CMD="keyword monitor $TARGET,preferred,0x0,1; keyword monitor $INTERNAL_MONITOR,$INTERNAL_RULE,auto,1"
        MSG="Extendiendo pantalla a la izquierda"
        ;;
    "Espejo (Mirror)")
        # Lógica idéntica a tu monitor.conf
        HYPR_CMD="keyword monitor $INTERNAL_MONITOR,$INTERNAL_RULE,auto,1; keyword monitor $TARGET,preferred,auto,1,mirror,$INTERNAL_MONITOR"
        MSG="Modo Espejo activado"
        ;;
    "Solo Externo")
        HYPR_CMD="keyword monitor $INTERNAL_MONITOR,disable; keyword monitor $TARGET,preferred,0x0,1"
        MSG="Usando solo monitor externo"
        ;;
    "Apagar Externo")
        HYPR_CMD="keyword monitor $TARGET,disable; keyword monitor $INTERNAL_MONITOR,$INTERNAL_RULE,0x0,1"
        MSG="Monitor externo desactivado"
        ;;
esac

# --- 4. EJECUCIÓN MAESTRA ---
# Aplicamos todo de un solo golpe para evitar glitches
hyprctl --batch "$HYPR_CMD"

# Notificación visual rápida
notify-send -t 2000 "Pantallas" "$MSG"

# --- 5. REFRESCO DE INTERFAZ (Optimizado para waypaper-git) ---
sleep 0.5
# Forzamos a Waypaper a redibujar el fondo en la nueva disposición de monitores
waypaper --restore > /dev/null 2>&1

# Reiniciar Waybar si es necesario para que se ajuste al nuevo tamaño/monitor
if pgrep -x "waybar" > /dev/null; then
    killall waybar
fi
waybar &