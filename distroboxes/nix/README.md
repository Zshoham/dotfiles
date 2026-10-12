# Nix distroboxes

NixOS replacements for the Arch based distrobox images in this directory.
The flake is standalone and does not depend on the rest of the repo.

## basebox

The tools from `Dockerfile.basebox` as a NixOS module (`basebox/module.nix`).
Files that the Arch image downloads at build time (zellij plugins, gef,
replay.fish) are pinned and packaged into `/run/current-system/sw/share`.

### On a NixOS host

```nix
{
  inputs.boxes.url = "github:Zshoham/dotfiles?dir=distroboxes/nix";

  # in the system modules
  imports = [ inputs.boxes.nixosModules.basebox ];
  basebox.enable = true;
}
```

### As a NixOS container

Declared on the host, sharing the network and the user's home directory
(the user needs a fixed `uid`):

```nix
{
  imports = [ inputs.boxes.nixosModules.basebox-container ];
  basebox.container = {
    enable = true;
    user = "shoham";
    # config = { ... };  # extra configuration for the container
  };
}
```

```sh
sudo nixos-container start basebox
machinectl shell shoham@basebox
```

Or imperatively from the flake (creates user `basebox`, uid 1000):

```sh
sudo nixos-container create basebox --flake github:Zshoham/dotfiles?dir=distroboxes/nix#basebox
sudo nixos-container start basebox
```

### Home setup

`basebox-init` replaces `init.sh`: it applies the dotfiles with chezmoi,
links the zellij plugins and gef into `~/.config`, installs the stable rust
toolchain with rustup and sets up the neovim config.
