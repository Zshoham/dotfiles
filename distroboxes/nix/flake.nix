{
  description = "Nix replacements for the distroboxes";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      mkContainer =
        name:
        nixpkgs.lib.nixosSystem {
          modules = [
            ./container.nix
            {
              nixpkgs.hostPlatform = system;
              networking.hostName = name;
              ${name}.enable = true;
            }
          ];
        };
    in
    {
      nixosModules.default = ./module.nix;

      # sudo nixos-container create workbox --flake .#workbox
      nixosConfigurations = {
        basebox = mkContainer "basebox";
        workbox = mkContainer "workbox";
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
