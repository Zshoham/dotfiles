# The conda layer: micromamba and pixi with `micromamba activate`. They are
# built by nix, but the conda packages they install are prebuilt and need a
# regular Linux layout, so the layer is only used in the FHS shells
# (fhs.nix). Conda packages bring their own libraries, the conda shell adds
# a few they commonly expect from the system.
{
  pkgs,
  runCommand,
  symlinkJoin,
  writeText,
}:

let
  # nixpkgs' micromamba is a wrapper script around mamba-cpp, whose shell
  # hook then only knows the binary as `.mamba-wrapped` and doesn't define
  # micromamba(). The binary itself, named micromamba.
  micromamba = runCommand "micromamba-${pkgs.mamba-cpp.version}" { } ''
    install -Dm755 ${pkgs.mamba-cpp}/bin/.mamba-wrapped $out/bin/micromamba
  '';

  tools = symlinkJoin {
    name = "conda-tools";
    paths = [
      micromamba
      pkgs.pixi
    ];
  };

  activate = writeText "conda-activate.sh" ''
    export PATH="${tools}/bin:$PATH"
    export MAMBA_ROOT_PREFIX="''${MAMBA_ROOT_PREFIX:-''${XDG_DATA_HOME:-$HOME/.local/share}/mamba}"
    eval "$(micromamba shell hook --shell bash)"
  '';
in
runCommand "conda-layer"
  {
    passthru.layerName = "conda";
  }
  ''
    mkdir -p $out
    ln -s ${tools}/bin $out/bin
    ln -s ${activate} $out/activate.sh
  ''
