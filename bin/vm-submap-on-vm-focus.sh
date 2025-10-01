#!/usr/bin/env bash

handle() {
  case $1 in
  "activewindow>>"*)
    payload=${line#*>>}
    IFS=',' read -r wclass wtitle <<<"$payload"
    if [[ $wclass == ".qemu-system-x86_64-wrapped" || $wclass == "Vmware" ]]; then
      hyprctl dispatch submap vm
    else
      hyprctl dispatch submap reset
    fi
    ;;
  esac
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
