{ config, pkgs, ...}:

{
  home.packages = [
    # misc
    (pkgs.nerdfonts.override { fonts = ["JetBrainsMono"]; })
    pkgs.neofetch

    # core utils.
    pkgs.fish
    pkgs.bat
    pkgs.exa
    pkgs.fd
    pkgs.procs
    pkgs.du-dust
    pkgs.sd
    pkgs.ripgrep
    pkgs.duf

    # git utils.
    pkgs.lazygit
    pkgs.delta

    # tui apps.
    pkgs.glow
    pkgs.slides
    pkgs.btop
    pkgs.neovim
    pkgs.zellij
    pkgs.lf
    pkgs.lazydocker

    # extra utils.
    pkgs.age
    pkgs.jq
    pkgs.bitwarden-cli
    pkgs.hexyl
    pkgs.fzf
    pkgs.chezmoi

    # programming languages
    pkgs.go
    pkgs.nodejs
    pkgs.julia-bin
    pkgs.jdk
  ];
}
