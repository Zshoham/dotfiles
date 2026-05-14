#!/bin/sh

TEMP_GIT_DIR=`mktemp -d`

git clone https://github.com/jorgebucaran/replay.fish.git "${TEMP_GIT_DIR}"

mkdir -p "${XDG_CONFIG_HOME}/fish/functions/"
mkdir -p "${XDG_CONFIG_HOME}/fish/completions/"

cp "${TEMP_GIT_DIR}/functions/"* "${XDG_CONFIG_HOME}/fish/functions/"
cp "${TEMP_GIT_DIR}/completions/"* "${XDG_CONFIG_HOME}/fish/completions/"

rm -rf "${TEMP_GIT_DIR}"
