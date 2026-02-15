#!/bin/bash

curl -fsSL https://opencode.ai/install | sed 's|INSTALL_DIR=$HOME/.*|INSTALL_DIR=/usr/bin|' | sudo bash -s -- --no-modify-path

WORK_DIR=`mktemp -d`

export XDG_CONFIG_HOME=$WORK_DIR/config
export XDG_DATA_HOME=$WORK_DIR/share
export XDG_STATE_HOME=$WORK_DIR/state
export XDG_CACHE_HOME=$WORK_DIR/cache
export HOME=$WORK_DIR/

curl -fsSL https://claude.ai/install.sh | bash

CLAUDE_BIN=`find $XDG_DATA_HOME/claude/ -type f`

sudo mv $CLAUDE_BIN /usr/bin/claude

rm -rf $WORK_DIR
