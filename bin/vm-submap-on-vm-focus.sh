#!/usr/bin/env bash

handle() {
  case $1 in
  "activewindow>>"*)
    payload=${1#*>>}
    IFS=',' read -r wclass wtitle <<<"$payload"
    if [[ $wclass == ".qemu-system-x86_64-wrapped" || $wclass == "Vmware" ]]; then
      hyprctl dispatch 'hl.dsp.submap("vm")'
    else
      hyprctl dispatch 'hl.dsp.submap("reset")'
    fi
    ;;
  esac
}

socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while IFS= read -r line; do handle "$line"; done
