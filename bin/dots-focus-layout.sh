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

# Quote selectors as Lua data, not code (JSON's \uXXXX escapes are not Lua).
lua_string() {
    local value=$1
    value=${value//\\/\\\\}
    value=${value//\"/\\\"}
    value=${value//$'\n'/\\n}
    value=${value//$'\r'/\\r}
    printf '"%s"' "$value"
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
        hyprctl dispatch "hl.dsp.focus({window=$(lua_string "address:$address")})"
        hyprctl dispatch 'hl.dsp.window.fullscreen({mode="fullscreen",action="set"})'
    done <<< "$addresses"
done

for i in "${!classes[@]}"; do
    addresses=$(jq -r --arg cls "${classes[$i]}" \
        '.[] | select(.class == $cls) | .address' <<< "$clients")
    while IFS= read -r address; do
        [[ -n "$address" ]] || continue
        hyprctl dispatch "hl.dsp.window.move({workspace=$(lua_string "${workspaces[$i]}"),window=$(lua_string "address:$address"),follow=false})"
    done <<< "$addresses"
done

for address in "${fullscreen_addresses[@]}"; do
    hyprctl dispatch "hl.dsp.focus({window=$(lua_string "address:$address")})"
    hyprctl dispatch 'hl.dsp.window.fullscreen({mode="fullscreen",action="unset"})'
    hyprctl dispatch 'hl.dsp.window.fullscreen({mode="fullscreen",action="set"})'
done

if [[ -n "$focus_workspace" ]]; then
    hyprctl dispatch "hl.dsp.focus({workspace=$(lua_string "$focus_workspace")})"
fi
