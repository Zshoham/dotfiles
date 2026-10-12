# Nix distroboxes

The programs from the distrobox Dockerfiles as a NixOS module. The flake is
standalone and does not depend on the rest of the repo. Programs are
configured by the chezmoi dotfiles as usual (`chezmoi init --apply Zshoham`).

- `basebox.enable`: programs from `Dockerfile.basebox`
- `workbox.enable`: programs from `Dockerfile.work`, implies `basebox`

`claude-code` (workbox) is unfree, so it has to be allowed in the host's
nixpkgs config.

The zellij plugins are installed to `/run/current-system/sw/share/zellij/plugins`
(zjstatus from `pkgs.zellijPlugins`, room and zellij-forgot built in
`zellij-plugins.nix`). On NixOS the zellij config in the dotfiles points
there instead of `~/.config/zellij/plugins`.

## On a NixOS host

```nix
{
  inputs.boxes.url = "github:Zshoham/dotfiles?dir=distroboxes/nix";

  # in the system modules
  imports = [ inputs.boxes.nixosModules.default ];
  workbox.enable = true;
}
```

## As a NixOS container

Imperatively from the flake (user `box`, passwordless sudo):

```sh
sudo nixos-container create workbox --flake github:Zshoham/dotfiles?dir=distroboxes/nix#workbox
sudo nixos-container start workbox
machinectl shell box@workbox
```

Or declared on the host, sharing the network and home directory:

```nix
containers.workbox = {
  bindMounts.home = { hostPath = "/home/shoham"; isReadOnly = false; };
  config = { pkgs, ... }: {
    imports = [ inputs.boxes.nixosModules.default ];
    workbox.enable = true;
    users.users.shoham = {
      isNormalUser = true;
      uid = 1000; # same as on the host
      extraGroups = [ "wheel" ];
      shell = pkgs.fish;
    };
    system.stateVersion = "26.05";
  };
};
```
