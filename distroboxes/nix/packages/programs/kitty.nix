# kitty with its config and theme from config/kitty.
{ pkgs, wrappers }:

(wrappers.wrapperModules.kitty.apply {
  inherit pkgs;
  # Use the config directory (kitty.conf includes current-theme.conf) instead
  # of --config, which would break `kitty +kitten ...` and is not inherited
  # by kittens started from kitty.
  flags."--config" = pkgs.lib.mkForce false;
  env.KITTY_CONFIG_DIRECTORY = "${../../config/kitty}";
}).wrapper
