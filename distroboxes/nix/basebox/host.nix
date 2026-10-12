# Host side module, declares the basebox container on a NixOS host.
#
# The container shares the host's network and the user's home directory,
# similar to a distrobox. Enter it with:
#   sudo nixos-container start basebox
#   machinectl shell <user>@basebox
{
  config,
  lib,
  ...
}:

let
  cfg = config.basebox.container;
  hostUser = config.users.users.${cfg.user};
in
{
  options.basebox.container = {
    enable = lib.mkEnableOption "the basebox NixOS container";

    user = lib.mkOption {
      type = lib.types.str;
      description = "Host user whose home directory is shared with the container.";
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to start the container on boot.";
    };

    config = lib.mkOption {
      type = lib.types.deferredModule;
      default = { };
      description = "Extra NixOS configuration for the container.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = hostUser.uid != null;
        message = "basebox.container: users.users.${cfg.user}.uid must be set so the shared home directory has the same owner in the container.";
      }
    ];

    containers.basebox = {
      inherit (cfg) autoStart;
      privateNetwork = false;

      bindMounts.home = {
        hostPath = hostUser.home;
        mountPoint = hostUser.home;
        isReadOnly = false;
      };

      config = {
        imports = [
          ./container.nix
          cfg.config
        ];

        basebox.container = {
          inherit (cfg) user;
          uid = hostUser.uid;
        };

        users.users.${cfg.user}.home = hostUser.home;
        system.stateVersion = config.system.stateVersion;
      };
    };
  };
}
