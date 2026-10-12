# The programs from the distrobox Dockerfiles as a NixOS module.
#
#   basebox.enable - Dockerfile.basebox
#   workbox.enable - Dockerfile.work (implies basebox)
#
# Programs are configured by the chezmoi dotfiles, this module installs them
# along with the plugins the Dockerfiles download (zellij plugins,
# replay.fish).
{
  config,
  lib,
  options,
  pkgs,
  ...
}:

let
  replay-fish =
    let
      src = pkgs.fetchgit {
        url = "https://github.com/jorgebucaran/replay.fish";
        rev = "1.2.1";
        hash = "sha256-bM6+oAd/HXaVgpJMut8bwqO54Le33hwO9qet9paK1kY=";
      };
    in
    pkgs.runCommand "replay-fish" { } ''
      install -Dm644 ${src}/functions/replay.fish $out/share/fish/vendor_functions.d/replay.fish
      install -Dm644 ${src}/completions/replay.fish $out/share/fish/vendor_completions.d/replay.fish
    '';

  # Installed to /run/current-system/sw/share/zellij/plugins, which the
  # zellij config in the dotfiles uses on NixOS.
  zellijPlugins =
    let
      extraPlugins = pkgs.callPackage ./zellij-plugins.nix { };
    in
    pkgs.linkFarm "zellij-plugins" {
      "share/zellij/plugins/zjstatus.wasm" = pkgs.zellijPlugins.zjstatus;
      "share/zellij/plugins/room.wasm" = extraPlugins.room;
      "share/zellij/plugins/zellij_forgot.wasm" = extraPlugins.zellij-forgot;
    };
in
{
  options = {
    basebox.enable = lib.mkEnableOption "the basebox programs";
    workbox.enable = lib.mkEnableOption "the workbox programs";
  };

  config = lib.mkMerge [
    (lib.mkIf config.workbox.enable {
      basebox.enable = true;

      environment.systemPackages = with pkgs; [
        ffmpeg
        (lib.hiPrio gcc_multi)
        gdb
        gef
        glab
        ltrace
        micromamba
        perf
        strace
        valgrind

        (callPackage ./yocto.nix { })
      ];

      programs.nix-ld.libraries = [ pkgs.libxcrypt-legacy ];
    })

    (lib.mkIf config.basebox.enable {
      environment.systemPackages = with pkgs; [
        # system utilities
        bc
        curl
        file
        gnupg
        (lib.lowPrio inetutils)
        keyutils
        lsof
        moreutils
        pinentry-curses
        rsync
        tcpdump
        time
        traceroute
        tree
        unzip
        wget
        zip

        # build tools (base-devel on arch)
        autoconf
        automake
        binutils
        gcc
        gnumake
        libtool
        pkg-config

        # cli tools
        age
        atuin
        bat
        btop
        chezmoi
        delta
        expect
        fd
        fzf
        git
        glow
        jq
        jujutsu
        lsd
        neovim
        ripgrep
        sd
        starship
        zellij
        zoxide
        replay-fish
        zellijPlugins

        # languages
        cargo
        clippy
        go
        nodejs
        python3
        rust-analyzer
        rustc
        rustfmt

        kitty.terminfo
      ];

      programs.fish.enable = true;

      environment.pathsToLink = [ "/share/zellij" ];

      # Lets prebuilt binaries run, e.g. language servers installed by mason.
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = options.programs.nix-ld.libraries.default;

      documentation.dev.enable = true;
    })
  ];
}
