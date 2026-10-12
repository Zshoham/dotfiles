# bat with its config and themes from config/bat.
{ pkgs, wrappers }:

let
  # what `bat cache --build` makes from the themes in the config directory
  cache = pkgs.runCommand "bat-cache" { nativeBuildInputs = [ pkgs.bat ]; } ''
    bat cache --build --source ${../../config/bat} --target $out
  '';
in
(wrappers.wrapperModules.bat.apply {
  inherit pkgs;
  "bat-config".path = "${../../config/bat/config}";
  env.BAT_CACHE_PATH = "${cache}";
}).wrapper
