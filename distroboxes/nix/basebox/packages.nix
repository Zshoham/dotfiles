# The basebox tool set, the nix equivalent of the package list in
# Dockerfile.basebox. Base system tools (coreutils, sudo, shadow, ...) are
# provided by NixOS itself and are not listed here.
{ pkgs }:

with pkgs;
[
  # system utilities
  bc
  bzip2
  curl
  diffutils
  file
  gnupg
  (lib.lowPrio inetutils)
  iputils
  keyutils
  lsof
  man-pages
  moreutils
  pinentry-curses
  rsync
  tcpdump
  time
  traceroute
  tree
  unzip
  wget
  which
  xz
  zip
  zstd

  # build tools (the arch image gets these from base-devel)
  autoconf
  automake
  binutils
  bison
  flex
  gcc
  gettext
  gnumake
  libtool
  m4
  patch
  pkg-config

  # shell & cli tools
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

  # languages
  go
  nodejs
  python3
  rustup

  kitty.terminfo
]
