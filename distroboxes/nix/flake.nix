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
      inherit (nixpkgs) lib;
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

      # Every environment: environments that need a regular Linux layout are
      # their shell (nix run .#workbox), the others their packages (nix shell
      # .#basebox, nix develop .#basebox).
      packages.${system} =
        lib.mapAttrs (_: env: env.package) packages.environments
        // packages.programs
        // {
          inherit (packages) zellij-plugins replay-fish;
        };

      devShells.${system} = lib.mapAttrs (
        name: _: pkgs.mkShellNoCC { packages = [ self.packages.${system}.${name} ]; }
      ) (lib.filterAttrs (_: env: !env.needsFhs) packages.environments);

      # sudo nixos-container create workbox --flake .#workbox
      nixosConfigurations = {
        basebox = mkContainer "basebox";
        workbox = mkContainer "workbox";
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
