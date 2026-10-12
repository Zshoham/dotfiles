# git with its config from config/git and the user's identity.
{
  pkgs,
  wrappers,
  identity,
}:

(wrappers.wrapperModules.git.apply {
  inherit pkgs;
  settings = {
    user = { inherit (identity) name email; };
    include.path = "${../../config/git}/config";
  };
  # the pager
  extraPackages = [ pkgs.delta ];
}).wrapper
