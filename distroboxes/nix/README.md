# Nix distroboxes

The programs from the distrobox Dockerfiles as a NixOS module. The flake is
standalone and does not depend on the rest of the repo. Programs are
configured by the chezmoi dotfiles as usual (`chezmoi init --apply Zshoham`).

- `basebox.enable`: programs from `Dockerfile.basebox`
- `workbox.enable`: programs from `Dockerfile.work`, implies `basebox`

With `workbox`, the `yocto` command enters an environment for building with
yocto (`packages/yocto.nix`), in place of the buildtools-extended SDK: an FHS
environment with the same toolchain (gcc 13) and the yocto host tools.

```sh
yocto
source poky/oe-init-build-env
bitbake core-image-minimal
```

The zellij plugins are installed to `/run/current-system/sw/share/zellij/plugins`
(zjstatus from `pkgs.zellijPlugins`, room and zellij-forgot built in
`packages/zellij-plugins.nix`). On NixOS the zellij config in the dotfiles points
there instead of `~/.config/zellij/plugins`.

## Packages

`packages/default.nix` defines the packages as named groups (`base`,
`utils`, `buildTools`, `shell`, `languages`, `debug`, `work`), used by both
the module and the yocto environment. The packages that are not in nixpkgs
are also flake outputs, e.g. `nix run .#yocto`.

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

Imperatively from the flake (user `build`, uid 30000, passwordless sudo):

```sh
sudo nixos-container create workbox --flake github:Zshoham/dotfiles?dir=distroboxes/nix#workbox
sudo nixos-container start workbox
machinectl shell build@workbox
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
