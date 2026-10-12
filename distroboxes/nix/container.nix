# A NixOS container with a single user, used by the nixosConfigurations in
# flake.nix.
{ lib, pkgs, ... }:

{
  imports = [ ./module.nix ];

  boot.isContainer = true;

  users.users.box = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };
  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfreePredicate = pkg: lib.getName pkg == "claude-code";

  system.stateVersion = "26.05";
}
