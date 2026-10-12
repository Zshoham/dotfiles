# zellij with its config from config/zellij, using the wrappers zellij
# module. The plugins are referenced from the store.
{
  pkgs,
  wrappers,
  zellij-plugins,
}:

let
  configDir = pkgs.runCommand "zellij-config" { } ''
    cp -r ${../config/zellij} $out
    chmod -R u+w $out
    substituteInPlace $out/config.kdl $out/layouts/base.kdl \
      --replace-fail @plugins@ ${zellij-plugins}/share/zellij/plugins

    # every plugin the config refers to has to exist
    grep -rho 'file:[^"]*' $out | cut -d: -f2 | while read -r plugin; do
      test -e "$plugin" || { echo "missing zellij plugin $plugin"; exit 1; }
    done
  '';
in
(wrappers.wrapperModules.zellij.apply {
  inherit pkgs;
  "config.kdl".path = "${configDir}/config.kdl";
  # for the layouts
  env.ZELLIJ_CONFIG_DIR = "${configDir}";
}).wrapper
