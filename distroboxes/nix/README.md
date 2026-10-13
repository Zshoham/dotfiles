# Nix distroboxes

The programs from the distrobox Dockerfiles as environments: a NixOS module
(`boxes.<environment>.enable`), NixOS containers, and shells and packages
usable without changing the system. The flake is standalone and does not
depend on the rest of the repo. Programs not yet configured here (see below)
are configured by the chezmoi dotfiles (`chezmoi init --apply Zshoham`).

## Environments

The boxes are environments: every file in `packages/environments` is a
module that defines some (`environments.<name>`, the options are in
`packages/environment.nix`). An environment has packages and can include
other environments by name, so it has everything they have:

- `basebox`: the programs of `Dockerfile.basebox`
- `yocto`: building with yocto, in place of the buildtools-extended SDK: the
  same toolchain (gcc 13) and the yocto host tools
- `conda`: conda based development with micromamba and pixi, with
  `micromamba activate` and the environments in `$MAMBA_ROOT_PREFIX`
  (default `~/.local/share/mamba`)
- `workbox`: the programs of `Dockerfile.work`, and includes `basebox`,
  `yocto` and `conda`

Every environment has a shell with everything it includes. `yocto` and
`conda` need a regular Linux layout (`/lib64/ld-linux...`, `/usr/lib`,
`fhs = true`): yocto's host tool checks expect it and conda packages are
prebuilt binaries, which run there without nix-ld. So the shells are FHS
environments, and installing an environment on a host (the NixOS module,
`nix shell`) installs the packages of the ones that don't need it and the
shells of the ones that do (and of every environment including them). The
workbox installs the basebox and workbox programs on the host, and the
`workbox`, `yocto` and `conda` shells:

```sh
yocto
source poky/oe-init-build-env
bitbake core-image-minimal

conda
micromamba create -n py -c conda-forge python
micromamba activate py
pixi init proj && cd proj && pixi add python && pixi run python

workbox       # all of it, e.g. a test from a conda environment using runqemu
```

There's no sudo in the shells, use `runqemu slirp` (or create the tap
devices with `runqemu-gen-tapdevs` beforehand).

An environment has `packages`, `includes` (names of environments), `fhs`, a
`profile` with environment variables, an `init` with bash setup (after
`~/.bashrc`), `hostOnlyPackages` that only go on the host (the workbox's
gcc 16 with multilib, so its shell keeps yocto's gcc 13) and `nixos`, the
NixOS configuration it needs on a host (the basebox's fish, the workbox's
rsyslog). From those it gets
its `closure`, `needsFhs`, `shell`, `hostPackages` and `package` (its shell
if it needs the layout, otherwise its host packages). Adding an environment
is adding a file, which also adds its `boxes.<name>.enable` option, flake
package, dev shell and container:

```nix
# packages/environments/example.nix
{ pkgs, groups, ... }:
{
  environments.example = {
    includes = [ "workbox" ];
    packages = [ pkgs.hello ];
    nixos.services.openssh.enable = true;
  };
}
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
| git      | `config/git`      | user from `boxes.identity`, delta on its PATH |
| jujutsu  | `config/jj`       | user from `boxes.identity` |
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

`boxes.identity.name` and `boxes.identity.email` default to Zshoham /
ShohamZarfti@gmail.com.

Until chezmoi is gone, the dotfiles include the same files for the Arch
boxes (zellij with its plugins in `~/.config/zellij/plugins`, git and jj
with the user from the chezmoi prompts).

## Without changing the system

Every environment is a flake package: the ones that need a regular Linux
layout are their shell, the others their packages. Every environment is
also a dev shell, the FHS shell for the ones that need it.

```sh
nix shell github:Zshoham/dotfiles?dir=distroboxes/nix#basebox    # add the basebox to the current shell
nix develop github:Zshoham/dotfiles?dir=distroboxes/nix#basebox  # bash with the basebox
nix run github:Zshoham/dotfiles?dir=distroboxes/nix#workbox      # the workbox shell
nix develop github:Zshoham/dotfiles?dir=distroboxes/nix#yocto    # the yocto shell
```

The environments' `nixos` configuration (services like rsyslog) is only
applied by the NixOS module. Neither box enables
nix-ld: everything they install is built by nix, and conda packages run in
`conda`.

## Packages

`packages/default.nix` defines the packages as named groups (`base`,
`utils`, `buildTools`, `shell`, `languages`, `debug`, `yocto`, `work`), which
the environments are made of, and the environments. The wrapped programs
and the packages that are not in nixpkgs are also flake outputs.

## On a NixOS host

```nix
{
  inputs.boxes.url = "github:Zshoham/dotfiles?dir=distroboxes/nix";

  # in the system modules
  imports = [ inputs.boxes.nixosModules.default ];
  boxes.workbox.enable = true;
}
```

`boxes.<environment>.enable` installs the environment's host packages and
applies the `nixos` configuration of every environment it includes.

## As a NixOS container

Every environment is a container (`nixosConfigurations.<environment>`).
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
    boxes.workbox.enable = true;
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
