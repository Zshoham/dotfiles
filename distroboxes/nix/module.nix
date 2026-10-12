# The programs from the distrobox Dockerfiles as a NixOS module.
#
#   basebox.enable - Dockerfile.basebox
#   workbox.enable - Dockerfile.work (implies basebox)
#
# Programs are configured by the chezmoi dotfiles, the packages are defined
# in packages/. Takes the wrappers library (wlib) from flake.nix.
{ wlib }:
{
  config,
  lib,
  options,
  pkgs,
  ...
}:

let
  packages = import ./packages { inherit pkgs wlib; };
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
