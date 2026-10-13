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
              boxes.${name}.enable = true;
            }
          ];
        };
    in
    {
      nixosModules.default = import ./module.nix {
        inherit wrappers;
        environmentNames = lib.attrNames packages.environments;
      };

      # Every environment: environments that need a regular Linux layout are
      # their shell (nix run .#workbox), the others their packages (nix shell
      # .#basebox, nix develop .#basebox).
      packages.${system} =
        lib.mapAttrs (_: env: env.package) packages.environments
        // packages.programs
        // {
          inherit (packages) zellij-plugins replay-fish;
        };

      # nix develop .#workbox
      devShells.${system} = lib.mapAttrs (
        _: env: if env.needsFhs then env.shell.env else pkgs.mkShellNoCC { packages = [ env.package ]; }
      ) packages.environments;

      # sudo nixos-container create workbox --flake .#workbox
      nixosConfigurations = lib.mapAttrs (name: _: mkContainer name) packages.environments;

      checks.${system} = import ./checks.nix {
        inherit pkgs packages;
        inherit (self) nixosConfigurations;
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
