# The packages of the boxes, as named groups shared by the NixOS module and
# the yocto environment, plus the packages that are not in nixpkgs.
{ pkgs }:

let
  inherit (pkgs) lib callPackage;
in
rec {
  replay-fish = callPackage ./replay-fish.nix { };
  zellij-plugins = callPackage ./zellij-plugins.nix { };
  yocto = callPackage ./yocto.nix { inherit groups; };

  groups = with pkgs; {
    # basic system tools, already part of NixOS but needed in FHS
    # environments
    base = [
      bash
      bzip2
      coreutils
      diffutils
      file
      findutils
      gawk
      gnugrep
      gnused
      gnutar
      gzip
      hostname
      iputils
      patch
      procps
      util-linux
      which
      xz
      zstd
    ];

    utils = [
      bc
      curl
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
    ];

    # base-devel on arch, without the compiler
    buildTools = [
      autoconf
      automake
      binutils
      git
      gnumake
      libtool
      perl
      pkg-config
    ];

    shell = [
      age
      atuin
      bat
      btop
      chezmoi
      delta
      expect
      fd
      fzf
      glow
      jq
      jujutsu
      lsd
      neovim
      replay-fish
      ripgrep
      sd
      starship
      zellij
      zellij-plugins
      zoxide
      kitty.terminfo
    ];

    languages = [
      cargo
      clippy
      go
      nodejs
      python3
      rust-analyzer
      rustc
      rustfmt
    ];

    debug = [
      gdb
      gef
      ltrace
      perf
      strace
      valgrind
    ];

    work = [
      ffmpeg
      glab
      micromamba
    ];
  };
}
