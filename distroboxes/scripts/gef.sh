#!/bin/sh

mkdir -p "${XDG_CONFIG_HOME}/gdb"
wget -O "${XDG_CONFIG_HOME}/gdb/gef.py" -q https://gef.blah.cat/py
