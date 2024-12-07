#!/bin/sh

mkdir -p $XDG_CONFIG_HOME/zellij/plugins/
curl -L "https://github.com/karimould/zellij-forgot/releases/latest/download/zellij_forgot.wasm" -o $XDG_CONFIG_HOME/zellij/plugins/zellij_forgot.wasm
curl -L "https://github.com/rvcas/room/releases/latest/download/room.wasm" -o $XDG_CONFIG_HOME/zellij/plugins/room.wasm
curl -L "https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm" -o $XDG_CONFIG_HOME/zellij/plugins/zjstatus.wasm

