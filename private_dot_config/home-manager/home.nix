{ config, pkgs, ...}:

{
  home.username = "sgame";
  home.homeDirectory = "/home/sgame";
  home.stateVersion = "22.05";
  fonts.fontconfig.enable = true;
}
