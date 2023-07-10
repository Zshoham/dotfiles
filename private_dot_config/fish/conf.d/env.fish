set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_STATE_HOME "$HOME/.local/state"
set -gx XDG_CACHE_HOME "$HOME/.cache"

set -gx EDITOR nvim

if not set -q PYENV_ROOT
    set -gx PYENV_ROOT "$XDG_DATA_HOME/pyenv"
end

if not set -q PIPX_HOME
    set -gx PIPX_HOME "$XDG_DATA_HOME/pipx"
end

set -gx CARGO_HOME "$XDG_DATA_HOME/cargo"
set -gx RUSTUP_HOME "$XDG_DATA_HOME/rusup"
set -gx GOPATH "$XDG_DATA_HOME/golang"
set -gx FNM_DIR "$XDG_DATA_HOME/fnm"
set -gx JULIA_DEPOT_PATH "$XDG_DATA_HOME/julia"
set -gx _JAVA_OPTIONS "-Djava.util.prefs.userRoot" "$XDG_CONFIG_HOME/java"

set -gx GNUPGHOME "$XDG_DATA_HOME/gnupg"
set -gx TERMINFO_DIRS "$XDG_DATA_HOME/terminfo:/usr/share/terminfo"
set -gx SQLITE_HISTORY "$XDG_DATA_HOME/sqlite_history"
set -gx DOCKER_CONFIG "$XDG_CONFIG_HOME/docker"

set -gx PATH $PATH "$HOME/.local/bin"
set -gx PATH $PATH "$CARGO_HOME/bin"
set -gx PATH $PATH "$PYENV_ROOT/bin"
set -gx PATH $PATH "$PYENV_ROOT/shims"
