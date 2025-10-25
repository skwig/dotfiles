#!/usr/bin/env sh

file=$(fzf) || exit
dots-start rider $file

