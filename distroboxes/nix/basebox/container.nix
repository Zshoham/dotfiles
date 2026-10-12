# Guest side configuration of the basebox NixOS container.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.basebox.container;
in
{
  imports = [ ./module.nix ];

  options.basebox.container = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "basebox";
      description = "Name of the user inside the container.";
    };

    uid = lib.mkOption {
      type = lib.types.int;
      default = 1000;
      description = ''
        UID of the user inside the container. Should match the host user
        when the home directory is shared with the host.
      '';
    };
  };

  config = {
    boot.isContainer = true;
    networking.hostName = lib.mkDefault "basebox";

    basebox.enable = true;

    users.users.${cfg.user} = {
      isNormalUser = true;
      uid = cfg.uid;
      extraGroups = [ "wheel" ];
      shell = pkgs.fish;
    };
    security.sudo.wheelNeedsPassword = false;

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    system.stateVersion = lib.mkDefault "26.05";
  };
}
