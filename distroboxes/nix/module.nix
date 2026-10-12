# The programs from the distrobox Dockerfiles as a NixOS module.
#
#   basebox.enable - Dockerfile.basebox
#   workbox.enable - Dockerfile.work (implies basebox)
#
# Programs are configured by the chezmoi dotfiles, the packages are defined
# in packages/.
{
  config,
  lib,
  options,
  pkgs,
  ...
}:

let
  packages = import ./packages { inherit pkgs; };
in
{
  options = {
    basebox.enable = lib.mkEnableOption "the basebox programs";
    workbox.enable = lib.mkEnableOption "the workbox programs";
  };

  config = lib.mkMerge [
    (lib.mkIf config.basebox.enable {
      environment.systemPackages =
        with packages.groups;
        base ++ utils ++ buildTools ++ shell ++ languages ++ [ pkgs.gcc ];

      programs.fish.enable = true;

      # zellij plugins, used by the zellij config in the dotfiles on NixOS
      environment.pathsToLink = [ "/share/zellij" ];

      # Lets prebuilt binaries run, e.g. language servers installed by mason.
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = options.programs.nix-ld.libraries.default;

      documentation.dev.enable = true;
    })

    (lib.mkIf config.workbox.enable {
      basebox.enable = true;

      environment.systemPackages =
        with packages.groups;
        debug
        ++ work
        ++ [
          (lib.hiPrio pkgs.gcc_multi)
          packages.yocto
        ];

      programs.nix-ld.libraries = [ pkgs.libxcrypt-legacy ];
    })
  ];
}
