# The conda environment: micromamba and pixi, with `micromamba activate`.
# Conda packages are prebuilt binaries that need a regular Linux layout
# (/lib64/ld-linux..., /usr/lib), which the shell provides instead of
# nix-ld.
{
  glibcLocales,
  runCommand,
  pkgs,
  groups,
}:

let
  # nixpkgs' micromamba is a wrapper script around mamba-cpp, whose shell
  # hook then only knows the binary as `.mamba-wrapped` and doesn't define
  # micromamba(). The binary itself, named micromamba.
  micromamba = runCommand "micromamba-${pkgs.mamba-cpp.version}" { } ''
    install -Dm755 ${pkgs.mamba-cpp}/bin/.mamba-wrapped $out/bin/micromamba
  '';
in
{
  name = "conda";

  packages =
    groups.base
    ++ groups.utils
    ++ [ micromamba ]
    ++ (with pkgs; [
      pixi
      git

      # libraries conda packages commonly expect from the system
      libxcrypt-legacy # libcrypt.so.1 (libxcrypt-compat in the workbox image)
      stdenv.cc.cc.lib
      zlib
    ]);

  profile = ''
    export LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive
    export MAMBA_ROOT_PREFIX="''${MAMBA_ROOT_PREFIX:-''${XDG_DATA_HOME:-$HOME/.local/share}/mamba}"
  '';

  init = ''
    eval "$(micromamba shell hook --shell bash)"
  '';
}
