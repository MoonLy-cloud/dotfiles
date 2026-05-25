#!/usr/bin/env bash

GAMEMODE_FILE="/tmp/hypr_gamemode_active"

# Función para controlar auto-cpufreq (Con SUDO)
set_cpu_mode() {
    if command -v auto-cpufreq &> /dev/null; then
        if [ "$1" == "performance" ]; then
            sudo auto-cpufreq --force=performance
        else
            sudo auto-cpufreq --force=reset
        fi
    fi
}

if [ -f "$GAMEMODE_FILE" ]; then
    # --- DESACTIVAR (Modo Normal) ---
    rm "$GAMEMODE_FILE"
    
    # 1. Restaurar Hyprland
    hyprctl keyword decoration:shadow:enabled true
    hyprctl keyword decoration:blur:enabled true
    hyprctl keyword animations:enabled true
    hyprctl keyword general:gaps_in 5
    hyprctl keyword general:gaps_out 10
    hyprctl keyword decoration:rounding 10
    
    # 2. Restaurar Energía
    set_cpu_mode "reset"
    
    # 3. REVIVIR LA BARRA Y FONDO (Importante)
    # Lanzamos waybar en segundo plano y disown para que no dependa de la terminal
    waybar & disown
    
    # Opcional: A veces al matar procesos gráficos, el fondo parpadea. 
    # Si usas swww, esto asegura que siga vivo.
    swww-daemon & disown

    notify-send "GAMEMODE OFF" "Waybar restaurada. Sistema normalizado." -i battery

else
    # --- ACTIVAR (Modo Juego) ---
    touch "$GAMEMODE_FILE"
    
    # 1. Optimizar Hyprland
    hyprctl keyword decoration:shadow:enabled false
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword animations:enabled false
    hyprctl keyword general:gaps_in 0
    hyprctl keyword general:gaps_out 0
    hyprctl keyword decoration:rounding 0
    
    # 2. Potencia Máxima
    set_cpu_mode "performance"
    
    # 3. MATAR LA BARRA (Modo Inmersivo)
    killall waybar
    
    notify-send "GAMEMODE ON" "🔥 MODO JUEGO: Waybar oculta, potencia al máximo." -i video-display
fi