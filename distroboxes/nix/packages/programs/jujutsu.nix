# jujutsu with its config from config/jj and the user's identity.
{
  pkgs,
  wrappers,
  identity,
}:

(wrappers.wrapperModules.jujutsu.apply {
  inherit pkgs;
  settings = builtins.fromTOML (builtins.readFile ../../config/jj/config.toml) // {
    user = { inherit (identity) name email; };
  };
}).wrapper
