#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: dots-focus-layout --place CLASS WORKSPACE [--place CLASS WORKSPACE ...] [--reset-fullscreen CLASS ...] [--focus-workspace WORKSPACE]

Example wrapper:
    exec dots-focus-layout \
        --place 'CLASS_A' 5 \
        --place 'CLASS_B' 7 \
        --place 'CLASS_C' 8 \
        --focus-workspace 5
EOF
}

die() {
    printf 'dots-focus-layout: %s\n' "$*" >&2
    exit 1
}

classes=()
workspaces=()
fullscreen_classes=()
focus_workspace=""

while (( $# )); do
    case "$1" in
        --place)
            (( $# >= 3 )) || die '--place requires CLASS and WORKSPACE'
            [[ -n "$2" && -n "$3" ]] || die 'CLASS and WORKSPACE must not be empty'
            classes+=("$2")
            workspaces+=("$3")
            shift 3
            ;;
        --reset-fullscreen)
            (( $# >= 2 )) || die '--reset-fullscreen requires CLASS'
            [[ -n "$2" ]] || die 'CLASS must not be empty'
            fullscreen_classes+=("$2")
            shift 2
            ;;
        --focus-workspace)
            (( $# >= 2 )) || die '--focus-workspace requires WORKSPACE'
            [[ -n "$2" ]] || die 'WORKSPACE must not be empty'
            focus_workspace="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "unknown argument: $1"
            ;;
    esac
done

(( ${#classes[@]} )) || die 'at least one --place is required (see --help)'

clients=$(hyprctl clients -j)

fullscreen_addresses=()
for cls in "${fullscreen_classes[@]}"; do
    addresses=$(jq -r --arg cls "$cls" \
        '.[] | select(.class == $cls) | .address' <<< "$clients")
    while IFS= read -r address; do
        [[ -n "$address" ]] || continue
        fullscreen_addresses+=("$address")
        hyprctl dispatch focuswindow "address:$address"
        hyprctl dispatch fullscreen 0 set
    done <<< "$addresses"
done

for i in "${!classes[@]}"; do
    addresses=$(jq -r --arg cls "${classes[$i]}" \
        '.[] | select(.class == $cls) | .address' <<< "$clients")
    while IFS= read -r address; do
        [[ -n "$address" ]] || continue
        hyprctl dispatch movetoworkspacesilent "${workspaces[$i]},address:$address"
    done <<< "$addresses"
done

for address in "${fullscreen_addresses[@]}"; do
    hyprctl dispatch focuswindow "address:$address"
    hyprctl dispatch fullscreen 0 unset
    hyprctl dispatch fullscreen 0 set
done

if [[ -n "$focus_workspace" ]]; then
    hyprctl dispatch workspace "$focus_workspace"
fi
