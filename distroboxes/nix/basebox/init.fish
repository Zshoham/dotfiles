#!/usr/bin/env fish
# One time setup of the home directory inside a basebox container.
# Everything that is not part of the image itself (dotfiles, neovim config,
# rust toolchains) is set up here.

set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME $HOME/.config
set -q XDG_DATA_HOME; or set -gx XDG_DATA_HOME $HOME/.local/share
set -q XDG_STATE_HOME; or set -gx XDG_STATE_HOME $HOME/.local/state
set -q XDG_CACHE_HOME; or set -gx XDG_CACHE_HOME $HOME/.cache

mkdir -p $HOME/.local/bin $XDG_CONFIG_HOME $XDG_DATA_HOME $XDG_STATE_HOME $XDG_CACHE_HOME

# dotfiles
if not test -d $XDG_DATA_HOME/chezmoi
    chezmoi init --apply Zshoham
end

# files shipped with the system, only linked if the dotfiles don't provide them
mkdir -p $XDG_CONFIG_HOME/zellij/plugins $XDG_CONFIG_HOME/gdb
for plugin in /run/current-system/sw/share/zellij/plugins/*.wasm
    set -l dest $XDG_CONFIG_HOME/zellij/plugins/(basename $plugin)
    test -e $dest; or ln -s $plugin $dest
end
test -e $XDG_CONFIG_HOME/gdb/gef.py; or ln -s /run/current-system/sw/share/gef/gef.py $XDG_CONFIG_HOME/gdb/gef.py

# rust
set -gx CARGO_HOME $XDG_DATA_HOME/cargo
set -gx RUSTUP_HOME $XDG_DATA_HOME/rustup
if not rustup toolchain list | string match -q 'stable*'
    rustup toolchain install stable --component rust-analyzer
    rustup default stable
end

# neovim
if not test -d $XDG_CONFIG_HOME/nvim
    git clone https://github.com/Zshoham/neovim.git $XDG_CONFIG_HOME/nvim
end
nvim --headless -c "lua require('updater').update_all()" +qa

bat cache --build
# fish asks before overwriting the current theme
echo y | fish_config theme save Catppuccin
