# Builds a shell from a list of environments (environments/): bash in a
# buildFHSEnv, which gives prebuilt binaries the regular Linux layout they
# need. An environment is an attribute set with
#
#   name      the shell is named after its environments, e.g. yocto-conda
#   packages  the packages of the shell's file system (/usr, /lib, ...)
#   profile   environment variables (optional)
#   init      bash setup, after ~/.bashrc (optional)
#
# and the shell has all of their packages, variables and setup.
{
  lib,
  buildFHSEnv,
  writeText,
  writeShellScript,
}:

environments:

let
  name = lib.concatMapStringsSep "-" (env: env.name) environments;

  # sourced by every shell, interactive or not
  init = writeText "${name}-init" (
    ''
      unset BASH_ENV
      case $- in *i*) PS1="(${lib.concatMapStringsSep "+" (env: env.name) environments}) $PS1" ;; esac
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
}
