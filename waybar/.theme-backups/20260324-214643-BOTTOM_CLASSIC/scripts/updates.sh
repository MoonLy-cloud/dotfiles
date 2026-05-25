#!/usr/bin/env bash

# --- CONFIGURACIÓN ---
AUR_HELPER="yay"

# --- MODO ACTUALIZACIÓN (Ventana Terminal) ---
if [ "$1" == "update" ]; then
    # El comando largo hace:
    # 1. clear: Limpia pantalla
    # 2. echo: Muestra el banner ASCII en verde
    # 3. sudo -v: Pide la contraseña INMEDIATAMENTE
    # 4. yay: Actualiza todo sin preguntar
    # 5. Llama a tu script de recarga maestro al final
    
    CMD="clear; \
    echo -e '\033[1;32m'; \
    echo '  ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗'; \
    echo '  ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║'; \
    echo '  ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║'; \
    echo '  ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║'; \
    echo '  ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║'; \
    echo '  ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝'; \
    echo '          UNATTENDED SYSTEM UPDATE PROTOCOL'; \
    echo -e '\033[0m'; \
    echo '🔑 Requiere autorización de administrador:'; \
    sudo -v; \
    $AUR_HELPER -Syu --noconfirm; \
    echo -e '\n\033[1;32m✔ SISTEMA ACTUALIZADO CORRECTAMENTE\033[0m'; \
    echo -e '\033[1;36m🔄 Recargando entorno (Hyprland, Waybar, Rofi)...\033[0m'; \
    ~/.config/hypr/scripts/reload.sh; \
    sleep 1"

    kitty --class update_float --title "System Update" sh -c "$CMD && nohup ~/.config/hypr/scripts/reload.sh & sleep 1"
    exit 0
fi

# --- MODO RECUENTO (Waybar Módulo) ---
OFFICIAL=$(checkupdates 2> /dev/null | wc -l)
AUR=$($AUR_HELPER -Qua 2> /dev/null | wc -l)
TOTAL=$((OFFICIAL + AUR))

if [ "$TOTAL" -eq "0" ]; then
    pkill -RTMIN+8 waybar
    hyprctl reload
    echo "{\"text\": \"\", \"tooltip\": \"Sistema actualizado\", \"class\": \"uptodate\"}"
    
else
    # Volvemos a un formato limpio para la barra
    TEXT="📦 $TOTAL"
    TOOLTIP="Paquetes Pendientes:\n Oficiales: $OFFICIAL\nru AUR: $AUR"
    
    if [ "$TOTAL" -gt 20 ]; then
        CLASS="critical"
    else
        CLASS="pending"
    fi

    echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\"}"
fi