# The environments (packages/environments) as a NixOS module:
#
#   boxes.<environment>.enable  install the environment (its host packages)
#                               and apply its NixOS configuration, and the
#                               ones of the environments it includes
#   boxes.identity              the user of git and jujutsu
#
# Takes the flake inputs it needs from flake.nix, and the environment names
# (the options can't depend on the module's pkgs).
{ wrappers, environmentNames }:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.boxes;
  packages = import ./packages {
    inherit pkgs lib wrappers;
    inherit (cfg) identity;
  };
  inherit (packages) environments;
  identity = import ./packages/identity.nix;
  # an environment's NixOS configuration applies when an enabled environment
  # includes it
  included =
    name:
    lib.any (
      other: cfg.${other}.enable && lib.any (env: env.name == name) environments.${other}.closure
    ) environmentNames;
in
{
  options.boxes = {
    identity = {
      name = lib.mkOption {
        type = lib.types.str;
        default = identity.name;
        description = "Name used by git and jujutsu.";
      };
      email = lib.mkOption {
        type = lib.types.str;
        default = identity.email;
        description = "Email used by git and jujutsu.";
      };
    };
  }
  // lib.genAttrs environmentNames (name: {
    enable = lib.mkEnableOption "the ${name} environment";
  });

  # mkIf per environment: which ones are enabled can't decide the shape of
  # the config
  config = lib.mkMerge (
    map (
      name:
      lib.mkMerge [
        (lib.mkIf cfg.${name}.enable { environment.systemPackages = environments.${name}.hostPackages; })
        (lib.mkIf (included name) environments.${name}.nixos)
      ]
    ) environmentNames
  );
}
