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

`mamba-shell` (workbox) is the same kind of environment for micromamba:
conda packages are prebuilt binaries that need a regular Linux layout, so
they run there without nix-ld. It sets up `micromamba activate`, with the
environments in `$MAMBA_ROOT_PREFIX` (default `~/.local/share/mamba`).

```sh
mamba-shell
micromamba create -n py -c conda-forge python
micromamba activate py
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
| kitty    | `config/kitty`    | flake package only, not part of the boxes (they only have its terminfo) |
| neovim   | `config/nvim`     | LazyVim, everything from nix, see below |
| starship | `config/starship.toml` | `starship init` points at the wrapper |
| zellij   | `config/zellij`   | plugins (zjstatus from `pkgs.zellijPlugins`, room and zellij-forgot from `packages/zellij-plugins.nix`) from the store |

### neovim

`packages/neovim` builds neovim with the whole LazyVim config from
`config/nvim` (from github:Zshoham/neovim, which the Arch boxes still clone
with chezmoi). Everything comes from nix, so nothing is downloaded or built
at runtime and the basebox doesn't need nix-ld:

- the plugins (`packages/neovim/plugins.nix`, by their lazy.nvim name),
  loaded by lazy.nvim through `dev.path`, from nixpkgs except the diffview
  fork, seeker.nvim and gitlab.nvim with its Go server
- the tree-sitter parsers and queries, as nvim-treesitter's `install_dir`
- the language servers and tools (mason is disabled), on neovim's PATH

The config is copied to the store with its `@...@` placeholders replaced by
those paths, and neovim is started with `-u` on it. `~/.config/nvim` is
ignored, and LazyVim extras are set in `config/nvim/lazyvim.json` (`:LazyExtras`
can't change it).

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

Services (rsyslog) are only set up by the NixOS module. Neither box enables
nix-ld: everything they install is built by nix, and conda packages run in
`mamba-shell`.

## Packages

`packages/default.nix` defines the packages as named groups (`base`,
`utils`, `buildTools`, `shell`, `languages`, `debug`, `yocto`, `work`) and
the full list of each box, used by the module, the box shells and the yocto
environment. The packages that are not in nixpkgs
are also flake outputs, e.g. `nix run .#yocto` or `nix run .#mamba-shell`.

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
