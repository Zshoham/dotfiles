# A shell for conda based development with micromamba and pixi (the conda
# layer), replacing nix-ld: conda packages are prebuilt binaries that need a
# regular Linux layout (/lib64/ld-linux..., /usr/lib).
#
#   conda                                # bash with micromamba set up
#   conda -c 'micromamba create ...'
{
  pkgs,
  glibcLocales,
  groups,
  layers,
  mkFhsShell,
}:

mkFhsShell {
  name = "conda";

  targetPkgs =
    _:
    groups.base
    ++ groups.utils
    ++ (with pkgs; [
      git

      # libraries conda packages commonly expect from the system
      libxcrypt-legacy # libcrypt.so.1 (libxcrypt-compat in the workbox image)
      stdenv.cc.cc.lib
      zlib
    ]);

  profile = ''
    export LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive
  '';

  layers = [ layers.conda ];
}
