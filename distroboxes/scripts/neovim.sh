#!/bin/sh

git clone https://github.com/Zshoham/neovim.git $XDG_CONFIG_HOME/nvim
./update_nvim
rm ./update_nvim
