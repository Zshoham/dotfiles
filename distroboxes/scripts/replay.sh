#!/bin/sh

TEMP_GIT_DIR=`mktemp -d`

git clone https://github.com/jorgebucaran/replay.fish.git "${TEMP_GIT_DIR}"

mkdir -p "${XDG_CONFIG_HOME}/fish/functions/"
mkdir -p "${XDG_CONFIG_HOME}/fish/completions/"

cp -r "${TEMP_GIT_DIR}/*" "${XDG_CONFIG_HOME}/fish/functions/"
cp -r "${TEMP_GIT_DIR}/*" "${XDG_CONFIG_HOME}/fish/completions/"

rm -rf "${TEMP_GIT_DIR}"
