#!/usr/bin/env sh

file=$(ls ~/.local/bin | skwig-dms-picker) || exit
$SHELL ~/.local/bin/$file
