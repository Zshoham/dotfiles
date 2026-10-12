# The basebox tool set as a NixOS module. Usable directly on a NixOS host
# or inside the basebox container.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.basebox;
  assets = pkgs.callPackage ./assets.nix { };
in
{
  options.basebox = {
    enable = lib.mkEnableOption "the basebox development environment";

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional packages to install alongside the basebox tools.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      import ./packages.nix { inherit pkgs; }
      ++ (with assets; [
        zellij-plugins
        gef
        replay-fish
        basebox-init
      ])
      ++ cfg.extraPackages;

    environment.pathsToLink = [
      "/share/zellij"
      "/share/gef"
    ];

    programs.fish.enable = true;
    programs.zsh.enable = lib.mkDefault true;

    # Lets prebuilt binaries (mason, npm, curl | sh installers) run.
    programs.nix-ld.enable = lib.mkDefault true;

    documentation.man.enable = lib.mkDefault true;
    documentation.dev.enable = lib.mkDefault true;
  };
}
