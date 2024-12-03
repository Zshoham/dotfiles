#!/bin/sh

mkdir -p $XDG_CONFIG_HOME/zellij/plugins/
curl -L "https://github.com/rvcas/room/releases/latest/download/room.wasm" -o $XDG_CONFIG_HOME/zellij/plugins/room.wasm
curl -L "https://github.com/dj94/zjstatus/releases/latest/download/zjstatus.wasm" -o $XDG_CONFIG_HOME/zellij/plugins/zjstatus.wasm

