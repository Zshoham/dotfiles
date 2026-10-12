# fish with the plugins from the Dockerfiles (replay.fish), found through
# the vendor directories in XDG_DATA_DIRS.
{
  pkgs,
  wrappers,
  replay-fish,
}:

wrappers.lib.wrapPackage {
  inherit pkgs;
  package = pkgs.fish;
  env.XDG_DATA_DIRS = "\${XDG_DATA_DIRS:+$XDG_DATA_DIRS:}${replay-fish}/share";
}
