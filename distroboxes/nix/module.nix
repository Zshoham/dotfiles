# The programs from the distrobox Dockerfiles as a NixOS module.
#
#   basebox.enable - Dockerfile.basebox
#   workbox.enable - Dockerfile.work (implies basebox)
#
# The packages, and the configuration moved over from chezmoi so far, are
# defined in packages/ and config/. Takes the flake inputs it needs from
# flake.nix.
{ wrappers }:
{
  config,
  lib,
  options,
  pkgs,
  ...
}:

let
  cfg = config.basebox;
  packages = import ./packages {
    inherit pkgs wrappers;
    inherit (cfg) identity;
  };
in
{
  options = {
    basebox.enable = lib.mkEnableOption "the basebox programs";
    basebox.identity = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "Zshoham";
        description = "Name used by git and jujutsu.";
      };
      email = lib.mkOption {
        type = lib.types.str;
        default = "ShohamZarfti@gmail.com";
        description = "Email used by git and jujutsu.";
      };
    };
    workbox.enable = lib.mkEnableOption "the workbox programs";
  };

  config = lib.mkMerge [
    (lib.mkIf config.basebox.enable {
      environment.systemPackages = packages.boxes.basebox;

      programs.fish = {
        enable = true;
        package = packages.programs.fish;
      };

      environment.pathsToLink = [ "/share/dict" ];

      # Lets prebuilt binaries run, e.g. language servers installed by mason.
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = options.programs.nix-ld.libraries.default;

      documentation.dev.enable = true;
    })

    (lib.mkIf config.workbox.enable {
      basebox.enable = true;

      environment.systemPackages = packages.boxes.workbox;

      programs.nix-ld.libraries = [ pkgs.libxcrypt-legacy ];

      services.rsyslogd.enable = lib.mkDefault true;
    })
  ];
}
