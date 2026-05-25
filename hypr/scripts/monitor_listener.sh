#!/usr/bin/env bash

# Definir tu monitor interno (cámbialo si no es eDP-1)
INTERNAL="eDP-1"

handle() {
  case $1 in
    monitoradded*)
      # Esperamos a que la señal se estabilice
      sleep 1
      # Ejecutamos el Wizard para configurar la nueva pantalla
      ~/.config/hypr/scripts/monitor_wizard.sh
      ;;
      
    monitorremoved*)
      # ¡AQUÍ ESTÁ LA MAGIA DEL RESET!
      # Cuando desconectas algo, forzamos la configuración segura.
      
      # 1. Avisar
      notify-send "Monitor" "Pantalla desconectada. Restaurando..." -i "computer"
      
      # 2. Resetear la configuración de monitores recargando tu archivo base
      # Esto borra las configuraciones raras del script y vuelve a lo que hay en monitor.conf
      hyprctl reload
      
      # 3. (Opcional de seguridad) Forzar explícitamente la laptop a su lugar
      # Por si el reload falla, esto es un "seguro de vida"
      hyprctl keyword monitor "$INTERNAL, preferred, 0x0, 1"
      
      # 4. Restaurar Waybar (a veces se queda bugueada al quitar monitores)
      killall waybar && waybar &
      ;;
  esac
}

# Escuchar el socket
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done