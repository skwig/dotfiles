#!/usr/bin/env bash
# Real API verification; no live links are changed and no compositor is started.
set -euo pipefail
cd "$(dirname "$0")/../.."
binary=${1:?usage: bash tests/hypr/verify.sh /path/to/Hyprland-0.57-or-newer}
version=$("$binary" --version)
version=${version%%$'\n'*}
if [[ ! $version =~ ^Hyprland[[:space:]]+([0-9]+)\.([0-9]+)\.([0-9]+) ]] ||
   (( BASH_REMATCH[1] == 0 && BASH_REMATCH[2] < 57 )); then
    echo "Hyprland 0.57 or newer required; got: $version" >&2
    exit 1
fi
printf '%s\n' "$version"
root=$PWD
fixture=$(mktemp -d /tmp/opencode/hypr-verify.XXXXXX)
trap 'rm -rf -- "$fixture"' EXIT
mkdir -p "$fixture/hypr-custom"
ln -s "$root/hypr" "$fixture/hypr"
for host in blackbox smallbox; do
    ln -sfn "$root/hypr/hyprland.monitors.$host.lua" "$fixture/hypr-custom/hyprland.monitors.lua"
    # main.cpp exits after initServer in --verify-config mode, before startup events.
    XDG_CONFIG_HOME=$fixture "$binary" --verify-config --config "$fixture/hypr/hyprland.lua" > "$fixture/$host.log" 2>&1
    cat "$fixture/$host.log"
    grep -q '^config ok$' "$fixture/$host.log"
    if grep -Ei 'deprecated|deprecation|on_created_empty workspace rule' "$fixture/$host.log"; then
        echo "Unexpected deprecated API usage in $host configuration" >&2
        exit 1
    fi
done
