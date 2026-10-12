# zellij with the plugins used by the dotfiles. The plugin directory is
# passed in ZELLIJ_PLUGINS_DIR, which the zellij config in the dotfiles
# reads.
{
  pkgs,
  wlib,
  zellij-plugins,
}:

wlib.wrapPackage {
  inherit pkgs;
  package = pkgs.zellij;
  env.ZELLIJ_PLUGINS_DIR = "\${ZELLIJ_PLUGINS_DIR:-${zellij-plugins}/share/zellij/plugins}";
}
