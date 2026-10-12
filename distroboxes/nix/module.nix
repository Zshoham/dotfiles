# The programs from the distrobox Dockerfiles as a NixOS module.
#
#   basebox.enable - Dockerfile.basebox
#   workbox.enable - Dockerfile.work (implies basebox)
#
# The packages, and the configuration moved over from chezmoi so far, are
# defined in packages/ and config/. Takes the wrappers flake from flake.nix.
{ wrappers }:
{
  config,
  lib,
  options,
  pkgs,
  ...
}:

let
  packages = import ./packages { inherit pkgs wrappers; };
in
{
  options = {
    basebox.enable = lib.mkEnableOption "the basebox programs";
    workbox.enable = lib.mkEnableOption "the workbox programs";
  };

  config = lib.mkMerge [
    (lib.mkIf config.basebox.enable {
      environment.systemPackages = packages.boxes.basebox;

      programs.fish = {
        enable = true;
        package = packages.fish;
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
