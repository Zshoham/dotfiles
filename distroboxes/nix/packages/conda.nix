# A shell for conda packages with micromamba and pixi, replacing nix-ld:
# conda packages are prebuilt binaries that need a regular Linux layout
# (/lib64/ld-linux..., /usr/lib), which the FHS environment provides.
#
#   conda                                # bash with micromamba set up
#   conda -c 'micromamba create ...'
{
  buildFHSEnv,
  glibcLocales,
  pkgs,
  groups,
}:

let
  # nixpkgs' micromamba is a wrapper script around mamba-cpp, whose shell
  # hook then only knows the binary as `.mamba-wrapped` and doesn't define
  # micromamba(). The binary itself, named micromamba.
  micromamba = pkgs.runCommand "micromamba-${pkgs.mamba-cpp.version}" { } ''
    install -Dm755 ${pkgs.mamba-cpp}/bin/.mamba-wrapped $out/bin/micromamba
  '';
in
buildFHSEnv {
  name = "conda";

  targetPkgs =
    _:
    groups.base
    ++ groups.utils
    ++ [ micromamba ]
    ++ (with pkgs; [
      pixi
      git

      # libraries conda packages expect from the system
      libxcrypt-legacy # libcrypt.so.1 (libxcrypt-compat in the workbox image)
      stdenv.cc.cc.lib
      zlib
    ]);

  profile = ''
    export LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive
    export MAMBA_ROOT_PREFIX="''${MAMBA_ROOT_PREFIX:-''${XDG_DATA_HOME:-$HOME/.local/share}/mamba}"
    export PS1="(conda) $PS1"
  '';

  # micromamba's shell hook (for `micromamba activate`), in interactive
  # shells after ~/.bashrc and in `conda -c ...` through BASH_ENV
  runScript =
    let
      hook = pkgs.writeText "conda-hook.sh" ''
        unset BASH_ENV
        eval "$(micromamba shell hook --shell bash)"
      '';
      bashrc = pkgs.writeText "conda-bashrc" ''
        [ -f ~/.bashrc ] && source ~/.bashrc
        source ${hook}
      '';
    in
    pkgs.writeShellScript "conda" ''
      if [ $# -gt 0 ]; then
        export BASH_ENV=${hook}
      fi
      exec bash --rcfile ${bashrc} "$@"
    '';
}
