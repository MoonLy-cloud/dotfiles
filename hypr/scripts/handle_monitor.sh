#!/bin/sh

handle() {
    case $1 in
        monitoradded*)
            # Espera que el monitor inicialice
            sleep 1
            waypaper --restore
        ;;
    esac
}

socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    handle "$line"
done