source $HOME/.config/exports

export SHELL=(which fish)

set fish_greeting
status is-login; and type -q pyenv; and pyenv init --path | source
status is-interactive; and type -q pyenv; and pyenv init - | source

starship init fish | source

zoxide init --cmd cd fish | source

atuin init --disable-up-arrow fish | source

# catpuccin theme for fzf
set -Ux FZF_DEFAULT_OPTS "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 --bind='tab:down'  --bind='btab:up'"

