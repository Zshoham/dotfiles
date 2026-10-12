# The programs from the distrobox Dockerfiles as a NixOS module.
#
#   basebox.enable - Dockerfile.basebox
#   workbox.enable - Dockerfile.work (implies basebox)
#
# Programs are configured by the chezmoi dotfiles, this module only installs
# them.
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
        claude-code
        ffmpeg
        (lib.hiPrio gcc_multi)
        gdb
        gef
        glab
        ltrace
        micromamba
        opencode
        perf
        strace
        valgrind
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

      # Lets prebuilt binaries run, e.g. language servers installed by mason.
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = options.programs.nix-ld.libraries.default;

      documentation.dev.enable = true;
    })
  ];
}
