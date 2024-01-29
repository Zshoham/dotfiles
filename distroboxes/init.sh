#!/bin/fish

sudo chown -R $USER:$USER /opt

mv /opt/build_home/config/* $HOME/.config/
mv /opt/build_home/share/* $HOME/.local/share/
mv /opt/build_home/state/* $HOME/.local/state/
mv /opt/build_home/cache/* $HOME/.local/cache/

for path in (find $HOME/.local/ -xtype l)
  ln -fs "$(readlink $path | sd "/opt/build_home/(?P<dir>)" $HOME'/.local/${dir}')" $path
end

sd "/opt/build_home/(?P<dir>)" $HOME'/.local/${dir}' (rg -l /opt/build_home $HOME/.local/)

chezmoi init --apply dotfiles/

bat cache --build

sudo rm -rf dotfiles/
sudo rm build.env
sudo rm -rf build_home/
sudo rm (status current-filename)
