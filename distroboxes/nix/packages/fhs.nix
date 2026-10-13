# Builds the FHS shells (yocto, conda): bash in a buildFHSEnv, which gives
# prebuilt binaries the regular Linux layout they need.
#
# The shells are made of layers. A layer is a package with an activate.sh
# that sets up the current shell (PATH, variables, functions), so it can
# also be imported into a shell that is already running:
#
#   import-env conda
#
# `layers` are activated when the shell starts, `imports` can be imported.
# A layer can't add files to the shell's /usr or /lib, those come from
# `targetPkgs` and are fixed when the shell starts.
{
  lib,
  buildFHSEnv,
  writeText,
  writeShellScript,
}:

{
  name,
  targetPkgs,
  profile ? "",
  layers ? [ ],
  imports ? [ ],
}:

let
  importNames = toString (map (layer: layer.layerName) imports);

  # sourced by every shell, interactive or not
  rc = writeText "${name}-rc" (
    ''
      unset BASH_ENV
      case $- in *i*) PS1="(${name}) $PS1" ;; esac
    ''
    + lib.concatMapStrings (layer: "source ${layer}/activate.sh\n") layers
    + lib.optionalString (imports != [ ]) ''
      import-env() {
        case "''${1-}" in
        ${lib.concatMapStrings (layer: ''
          ${layer.layerName})
            source ${layer}/activate.sh
            case $- in *i*) PS1="(${layer.layerName}) $PS1" ;; esac
            ;;
        '') imports}
        *)
          echo "usage: import-env <environment>, available: ${importNames}" >&2
          return 1
          ;;
        esac
      }
      complete -W "${importNames}" import-env
    ''
  );

  # interactive shells, after the user's own bashrc
  bashrc = writeText "${name}-bashrc" ''
    [ -f ~/.bashrc ] && source ~/.bashrc
    source ${rc}
  '';
in
buildFHSEnv {
  inherit name targetPkgs profile;
  passthru = { inherit layers imports; };
  runScript = writeShellScript name ''
    # non-interactive shells (`${name} -c ...`) get the rc through BASH_ENV
    if [ $# -gt 0 ]; then
      export BASH_ENV=${rc}
    fi
    exec bash --rcfile ${bashrc} "$@"
  '';
}
