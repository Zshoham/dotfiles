# The packages of the boxes, as named groups shared by the NixOS module, the
# box environments and the yocto environment, plus the packages that are not
# in nixpkgs.
{
  pkgs,
  # separate from pkgs, so the NixOS module can find the environments'
  # options without evaluating its pkgs
  lib ? pkgs.lib,
  wrappers,
  # used by git and jujutsu
  identity ? import ./identity.nix,
}:

let
  inherit (pkgs) callPackage;
in
rec {
  replay-fish = callPackage ./replay-fish.nix { };
  zellij-plugins = callPackage ./zellij-plugins.nix { };

  # Programs wrapped with their configuration from config/.
  programs = {
    bat = callPackage ./programs/bat.nix { inherit wrappers; };
    btop = callPackage ./programs/btop.nix { inherit wrappers; };
    fish = callPackage ./programs/fish.nix { inherit wrappers replay-fish; };
    git = callPackage ./programs/git.nix { inherit wrappers identity; };
    jujutsu = callPackage ./programs/jujutsu.nix { inherit wrappers identity; };
    kitty = callPackage ./programs/kitty.nix { inherit wrappers; };
    neovim = callPackage ./neovim { inherit wrappers; };
    starship = callPackage ./programs/starship.nix { inherit wrappers; };
    zellij = callPackage ./programs/zellij.nix { inherit wrappers zellij-plugins; };
  };

  # The environments (environment.nix), one module per file in
  # environments/: the boxes, and the yocto and conda environments that need
  # a regular Linux layout. Each has a shell of its own and the packages
  # that install it on a host.
  environments =
    (lib.evalModules {
      modules = [
        (import ./environment.nix {
          inherit lib;
          inherit (pkgs)
            buildEnv
            buildFHSEnv
            glibcLocales
            writeText
            writeShellScript
            ;
        })
      ]
      ++ lib.mapAttrsToList (file: _: ./environments + "/${file}") (builtins.readDir ./environments);
      specialArgs = { inherit pkgs groups programs; };
    }).config.environments;

  # The wrapped programs take precedence over the ones in pkgs.
  groups = with pkgs // programs; {
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
      iputils
      ncurses
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
      pciutils
      pinentry-curses
      psmisc
      rsync
      # words, in /run/current-system/sw/share/dict
      scowl
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
      bison
      debugedit
      fakeroot
      flex
      gettext
      git
      gnumake
      groff
      libtool
      m4
      perl
      pkg-config
      texinfo
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
      fish
      fzf
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
      pkgs.kitty.terminfo
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

    # yocto.sh
    yocto = [
      chrpath
      cpio
      diffstat
      rpcsvc-proto
    ];

    work = [
      ffmpeg
      glab
      rsyslog
    ];
  };
}
