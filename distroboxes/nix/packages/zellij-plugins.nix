# The zellij plugins used by the dotfiles, in share/zellij/plugins.
# zjstatus is in nixpkgs, the others are built the same way as
# pkgs.zellijPlugins.
{
  lib,
  fetchFromGitHub,
  linkFarm,
  pkgsCross,
  zellijPlugins,
}:

let
  wasmPkgs = pkgsCross.wasm32-wasip1;

  buildPlugin =
    attrs:
    zellijPlugins.wrapper attrs.pname (
      (wasmPkgs.rustPlatform.buildRustPackage attrs).overrideAttrs (old: {
        # same workaround as pkgs.zellijPlugins
        nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [ wasmPkgs.lld ];
        env = old.env or { } // {
          RUSTFLAGS = old.env.RUSTFLAGS or "" + " -C linker=wasm-ld";
        };
      })
    );

  room = buildPlugin rec {
    pname = "room";
    version = "1.2.1";
    src = fetchFromGitHub {
      owner = "rvcas";
      repo = "room";
      tag = "v${version}";
      hash = "sha256-KHCt4U0uqK/qkTGq2/Jf5bqBBhVDqAgFh80RPpU/KY0=";
    };
    cargoHash = "sha256-CtaMzE72YV/DPPhjxL6LCvA03J8MneSOnMdy4mkyXvE=";
    meta = {
      description = "Zellij plugin for quickly searching and switching tabs";
      homepage = "https://github.com/rvcas/room";
      license = lib.licenses.mit;
    };
  };

  zellij-forgot = buildPlugin rec {
    pname = "zellij-forgot";
    version = "0.4.2";
    src = fetchFromGitHub {
      owner = "karimould";
      repo = "zellij-forgot";
      tag = version;
      hash = "sha256-QS09lC6yyUZA13PHERrdY/phfo1QoHAmRPpQUGL3pP8=";
    };
    cargoHash = "sha256-GR3bg6Rf6opb0jh8Hyv1y7gpsBh8nRExPjcGzIafHXg=";
    meta = {
      description = "Zellij plugin for showing your keybindings";
      homepage = "https://github.com/karimould/zellij-forgot";
      license = lib.licenses.mit;
    };
  };
in
linkFarm "zellij-plugins" {
  "share/zellij/plugins/zjstatus.wasm" = zellijPlugins.zjstatus;
  "share/zellij/plugins/room.wasm" = room;
  "share/zellij/plugins/zellij_forgot.wasm" = zellij-forgot;
}
