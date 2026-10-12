# starship with its config from config/starship.toml.
{
  lib,
  pkgs,
  wrappers,
}:

let
  starship = lib.getExe pkgs.starship;
in
(wrappers.wrapperModules.starship.apply {
  inherit pkgs;
  configFile.path = "${../../config/starship.toml}";
  # `starship init` prints the path of the running binary, which is the
  # unwrapped one, point the shell integration at the wrapper instead.
  preHook = ''
    if [ "''${1-}" = init ]; then
      ${starship} "$@" | sed "s|${starship}|$0|g"
      exit
    fi
  '';
}).wrapper
