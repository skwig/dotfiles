#!/usr/bin/env sh

file=$(ls ~/.local/bin | rofi -dmenu -i) || exit
$SHELL ~/.local/bin/$file
