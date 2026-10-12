{
  description = "Nix replacements for the distroboxes";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    wrappers = {
      url = "git+https://github.com/Lassulus/wrappers";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      wrappers,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      packages = import ./packages { inherit pkgs wrappers; };

      mkContainer =
        name:
        nixpkgs.lib.nixosSystem {
          modules = [
            self.nixosModules.default
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
      nixosModules.default = import ./module.nix { inherit wrappers; };

      # nix shell .#workbox, nix run .#yocto
      packages.${system} =
        packages.envs
        // packages.programs
        // {
          inherit (packages) yocto zellij-plugins replay-fish;
        };

      # nix develop .#workbox
      devShells.${system} = pkgs.lib.mapAttrs (
        _: env: pkgs.mkShellNoCC { packages = [ env ]; }
      ) packages.envs;

      # sudo nixos-container create workbox --flake .#workbox
      nixosConfigurations = {
        basebox = mkContainer "basebox";
        workbox = mkContainer "workbox";
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
