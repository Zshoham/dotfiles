export SHELL=(which fish)

set fish_greeting

set -gx MAMBA_EXE "/usr/bin/micromamba"
if test -f $MAMBA_EXE
  set -gx MAMBA_ROOT_PREFIX "/home/build/.local/share/mamba"
  $MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
end

starship init fish | source

zoxide init --cmd cd fish | source

atuin init --disable-up-arrow fish | source

# catpuccin theme for fzf
set -Ux FZF_DEFAULT_OPTS "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 --bind='tab:down'  --bind='btab:up'"

