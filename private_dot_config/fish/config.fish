export SHELL=(which fish)

set fish_greeting

status is-login; and type -q pyenv; and pyenv init --path | source
status is-interactive; and type -q pyenv; and pyenv init - | source

starship init fish | source

zoxide init fish | source
