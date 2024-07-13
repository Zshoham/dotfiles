#!/bin/fish

sudo chown -R $USER:$USER /opt

mkdir -p $HOME/.local/bin/ $XDG_CONFIG_HOME $XDG_DATA_HOME $XDG_STATE_HOME $XDG_CACHE_HOME

sudo cp -a --update=all /opt/build_home/config/ $XDG_CONFIG_HOME
sudo cp -a --update=all /opt/build_home/share/ $XDG_DATA_HOME
sudo cp -a --update=all /opt/build_home/state/ $XDG_STATE_HOME
sudo cp -a --update=all /opt/build_home/cache/ $XDG_CACHE_HOME

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
