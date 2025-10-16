#!/usr/bin/env sh

file=$(fzf) || exit
rider $file

