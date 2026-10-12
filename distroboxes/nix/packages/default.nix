# The packages of the boxes, as named groups shared by the NixOS module, the
# box environments and the yocto environment, plus the packages that are not
# in nixpkgs.
{
  pkgs,
  wrappers,
  # the neovim config (github:Zshoham/neovim), for its external.json
  nvim-config,
  # used by git and jujutsu
  identity ? {
    name = "Zshoham";
    email = "ShohamZarfti@gmail.com";
  },
}:

let
  inherit (pkgs) lib callPackage;
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
    neovim = callPackage ./neovim { inherit wrappers nvim-config; };
    starship = callPackage ./programs/starship.nix { inherit wrappers; };
    zellij = callPackage ./programs/zellij.nix { inherit wrappers zellij-plugins; };
  };

  yocto = callPackage ./yocto.nix { inherit groups; };

  # The full package list of each box.
  boxes = {
    basebox = with groups; base ++ utils ++ buildTools ++ shell ++ languages ++ [ pkgs.gcc ];

    workbox =
      with groups;
      boxes.basebox
      ++ debug
      ++ work
      ++ groups.yocto
      ++ [
        (lib.hiPrio pkgs.gcc_multi)
        yocto
      ];
  };

  # Each box as a single package, for nix shell / nix develop.
  envs = lib.mapAttrs (name: paths: pkgs.buildEnv { inherit name paths; }) boxes;

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
      micromamba
      rsyslog
    ];
  };
}
