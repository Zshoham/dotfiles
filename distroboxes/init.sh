#/bin/bash

sudo chown -R $USER:$USER /opt
chezmoi init --apply dotfiles/

sudo rm -rf dotfiles/
sudo rm -- "$0"
