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
    in
    {
      nixosModules = {
        # The basebox tools, for use directly on a NixOS host.
        basebox = ./basebox/module.nix;
        # Declares the basebox container on a NixOS host.
        basebox-container = ./basebox/host.nix;
      };

      # Standalone container system, for imperative nixos-container use:
      #   sudo nixos-container create basebox --flake .#basebox
      nixosConfigurations.basebox = nixpkgs.lib.nixosSystem {
        modules = [
          ./basebox/container.nix
          { nixpkgs.hostPlatform = system; }
        ];
      };

      packages.${system}.basebox = self.nixosConfigurations.basebox.config.system.build.toplevel;

      formatter.${system} = pkgs.nixfmt;
    };
}
