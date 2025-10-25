#!/usr/bin/env bash

ROOT=~/Projects/

file=$({
  find "$ROOT" -mindepth 2 -maxdepth 2 -type f -name '*.sln' -print0

  comm -z -23 \
    <(find "$ROOT" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z) \
    <(find "$ROOT" -mindepth 2 -maxdepth 2 -type f -name '*.sln' -printf '%h\0' | sort -z | uniq -z)
  } | xargs -0 -I{} realpath --relative-to="$ROOT" -- "{}" | rofi -dmenu -i) || exit

rider ~/Projects/$file
