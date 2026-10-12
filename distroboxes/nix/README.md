# Nix distroboxes

The programs from the distrobox Dockerfiles as a NixOS module. The flake is
standalone and does not depend on the rest of the repo. Programs not
yet configured here (see below) are configured by the chezmoi dotfiles
(`chezmoi init --apply Zshoham`).

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

## Configuration

Configuration is moving from chezmoi into this flake. The config files are
in `config/`, and `packages/programs/` wraps each program with its config
using [wrappers](https://github.com/Lassulus/wrappers), so the nix versions
don't read anything from `~/.config`:

| program  | config            | notes |
|----------|-------------------|-------|
| bat      | `config/bat`      | theme cache built at build time |
| btop     | `config/btop`     | |
| fish     | (chezmoi)         | finds replay.fish through `XDG_DATA_DIRS` |
| git      | `config/git`      | user from `basebox.identity`, delta on its PATH |
| jujutsu  | `config/jj`       | user from `basebox.identity` |
| kitty    | `config/kitty`    | flake package only, not part of the boxes |
| neovim   | (own repo)        | external dependencies from nix, see below |
| starship | `config/starship.toml` | `starship init` points at the wrapper |
| zellij   | `config/zellij`   | plugins (zjstatus from `pkgs.zellijPlugins`, room and zellij-forgot from `packages/zellij-plugins.nix`) from the store |

### neovim

The neovim config itself stays in its own repo (cloned to `~/.config/nvim`
by chezmoi), but its external dependencies come from nix
(`packages/neovim`), read from the config's `external.json` through the
`nvim-config` flake input:

- the tools it installs with mason are on neovim's PATH, mapped to nixpkgs
  in `packages/neovim/tools.nix` (the build fails for an unmapped tool)
- the tree-sitter parsers and queries are in a prebuilt nvim-treesitter
  install directory (the build fails for an unknown language)
- nvim-treesitter, blink.cmp (with its Rust fuzzy matcher),
  markdown-preview.nvim and gitlab.nvim (with its Go server) come from nix

The wrapper passes their locations in `vim.g.nix`, and the config's
`lua/plugins/nix.lua` then turns off mason and uses them. Without the
wrapper, the config installs everything itself as before.

`basebox.identity.name` and `basebox.identity.email` default to Zshoham /
ShohamZarfti@gmail.com.

Until chezmoi is gone, the dotfiles include the same files for the Arch
boxes (zellij with its plugins in `~/.config/zellij/plugins`, git and jj
with the user from the chezmoi prompts).

## Without changing the system

Each box is also a package and a dev shell:

```sh
nix shell github:Zshoham/dotfiles?dir=distroboxes/nix#workbox    # add to the current shell
nix develop github:Zshoham/dotfiles?dir=distroboxes/nix#workbox  # bash with the box
nix run github:Zshoham/dotfiles?dir=distroboxes/nix#yocto        # just the yocto environment
```

Services (rsyslog) and nix-ld are only set up by the NixOS module.

## Packages

`packages/default.nix` defines the packages as named groups (`base`,
`utils`, `buildTools`, `shell`, `languages`, `debug`, `yocto`, `work`) and
the full list of each box, used by the module, the box shells and the yocto
environment. The packages that are not in nixpkgs
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
