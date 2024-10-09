#!/bin/fish

if test (id -u) -ne 0
  sudo chown -R $USER:$USER /opt
end

bash miniforge3.sh -b -p /opt/miniforge3
rm miniforge3.sh

if not set -q $XDG_CONFIG_HOME
  set XDG_CONFIG_HOME $HOME/.config
end
if not set -q $XDG_DATA_HOME
  set XDG_DATA_HOME $HOME/.local/share
end
if not set -q $XDG_STATE_HOME
  set XDG_STATE_HOME $HOME/.local/state
end
if not set -q $XDG_CACHE_HOME
  set XDG_CACHE_HOME $HOME/.cache/
end

mkdir -p $HOME/.local/bin/ $XDG_CONFIG_HOME $XDG_DATA_HOME $XDG_STATE_HOME $XDG_CACHE_HOME

sudo cp -a --update=all /opt/build_home/config/* $XDG_CONFIG_HOME
sudo cp -a --update=all /opt/build_home/share/* $XDG_DATA_HOME
sudo cp -a --update=all /opt/build_home/state/* $XDG_STATE_HOME
sudo cp -a --update=all /opt/build_home/cache/* $XDG_CACHE_HOME

if test -d /opt/build_home/bin/
  sudo cp -a --update=all /opt/build_home/bin/ $HOME/.local/bin/
end

for path in (fd . $HOME/.local/ -t l)
  ln -fs "$(readlink $path | sd "/opt/build_home/(?P<dir>)" $HOME'/.local/${dir}')" $path
end

sd "/opt/build_home/(?P<dir>)" $HOME'/.local/${dir}' (rg -l /opt/build_home $HOME/.local/)

chezmoi init --apply dotfiles/

bat cache --build

sudo rm -rf dotfiles/
sudo rm build.env
sudo rm -rf build_home/
sudo rm (status current-filename)
