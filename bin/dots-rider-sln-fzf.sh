#!/usr/bin/env sh

file=$(fd -e sln | fzf) || exit
setsid dots-start rider "$file" >/dev/null 2>&1 &
