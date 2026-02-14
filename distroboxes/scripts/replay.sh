#!/bin/sh

TEMP_GIT_DIR=`mktemp -d`

git clone https://github.com/jorgebucaran/replay.fish.git "${TEMP_GIT_DIR}"

mkdir -p "${XDG_CONFIG_HOME}/fish/functions/
mkdir -p "${XDG_CONFIG_HOME}/fish/completions/

cp /tmp/replay__fish__repo/functions/* "${XDG_CONFIG_HOME}/fish/functions/"
cp /tmp/replay__fish__repo/completions/* "${XDG_CONFIG_HOME}/fish/completions/"

rm -rf "${TEMP_GIT_DIR}"
