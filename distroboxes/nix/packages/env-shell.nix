# Environments that need a regular Linux layout, and the shells built from
# them: bash in a buildFHSEnv, which gives prebuilt binaries the regular
# Linux layout they need. An environment (environments/) is an attribute
# set with
#
#   name      the name of its own shell
#   packages  the packages of the shell's file system (/usr, /lib, ...)
#   profile   environment variables (optional)
#   init      bash setup, after ~/.bashrc (optional)
{
  lib,
  buildFHSEnv,
  writeText,
  writeShellScript,
}:

rec {
  # A shell with all the packages, variables and setup of `environments`.
  mkShell =
    { name, environments }:
    let
      # sourced by every shell, interactive or not
      init = writeText "${name}-init" (
        ''
          unset BASH_ENV
          case $- in *i*) PS1="(${name}) $PS1" ;; esac
        ''
        + lib.concatMapStrings (env: env.init or "") environments
      );

      # interactive shells, after the user's own bashrc
      bashrc = writeText "${name}-bashrc" ''
        [ -f ~/.bashrc ] && source ~/.bashrc
        source ${init}
      '';
    in
    buildFHSEnv {
      inherit name;
      targetPkgs = _: lib.unique (lib.concatMap (env: env.packages) environments);
      profile = lib.concatMapStrings (env: env.profile or "") environments;
      passthru = { inherit environments; };
      runScript = writeShellScript name ''
        # non-interactive shells (`${name} -c ...`) get the setup through BASH_ENV
        if [ $# -gt 0 ]; then
          export BASH_ENV=${init}
        fi
        exec bash --rcfile ${bashrc} "$@"
      '';
    };

  # An environment, with `shell`: a shell of only this environment.
  mkEnvironment =
    env:
    env
    // {
      shell = mkShell {
        inherit (env) name;
        environments = [ env ];
      };
    };
}
