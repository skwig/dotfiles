#!/usr/bin/env sh

file=$(rider-picker ~/Projects | rofi -dmenu -i) || exit
rider ~/Projects/$file
