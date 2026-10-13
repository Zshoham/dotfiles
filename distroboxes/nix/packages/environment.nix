# Environments: sets of packages that can include each other, each with a
# shell of its own. An environment (environments/) is an attribute set with
#
#   name          the name of its shell
#   packages      its packages
#   includes      environments it includes (optional), recursively
#   fhs           whether it needs a regular Linux layout (/lib64/ld-linux...,
#                 /usr/lib) to work, e.g. for prebuilt binaries (optional)
#   profile       environment variables (optional)
#   init          bash setup, after ~/.bashrc (optional)
#   hostOnlyPackages
#                 packages only for the host, not the shell (optional)
#
# mkEnvironment adds
#
#   closure       the environment and everything it includes, each once
#   needsFhs      whether it or something it includes needs the layout
#   shell         a shell with all of the closure: bash in a buildFHSEnv
#   hostPackages  what installs the environment on a host (NixOS module,
#                 nix shell): the packages of the closure that work on the
#                 host, and the shells of the ones that need the layout
{
  lib,
  buildFHSEnv,
  writeText,
  writeShellScript,
}:

let
  # depth first, included environments before the ones including them,
  # every environment once
  closureOf =
    env:
    lib.foldl' (acc: e: if lib.any (a: a.name == e.name) acc then acc else acc ++ [ e ]) [ ] (
      lib.concatMap closureOf (env.includes or [ ]) ++ [ env ]
    );

  # whether the environment, or one it includes, needs the layout
  needsFhs = env: env.fhs or false || lib.any needsFhs (env.includes or [ ]);

  mkShell =
    { name, closure }:
    let
      # sourced by every shell, interactive or not
      init = writeText "${name}-init" (
        ''
          unset BASH_ENV
          case $- in *i*) PS1="(${name}) $PS1" ;; esac
        ''
        + lib.concatMapStrings (env: env.init or "") closure
      );

      # interactive shells, after the user's own bashrc
      bashrc = writeText "${name}-bashrc" ''
        [ -f ~/.bashrc ] && source ~/.bashrc
        source ${init}
      '';
    in
    buildFHSEnv {
      inherit name;
      targetPkgs = _: lib.unique (lib.concatMap (env: env.packages) closure);
      profile = lib.concatMapStrings (env: env.profile or "") closure;
      runScript = writeShellScript name ''
        # non-interactive shells (`${name} -c ...`) get the setup through BASH_ENV
        if [ $# -gt 0 ]; then
          export BASH_ENV=${init}
        fi
        exec bash --rcfile ${bashrc} "$@"
      '';
    };
in
{
  mkEnvironment =
    env:
    let
      self = env // {
        closure = map (e: if e.name == env.name then self else e) (closureOf env);
        needsFhs = needsFhs env;
        shell = mkShell {
          inherit (env) name;
          inherit (self) closure;
        };
        hostPackages = lib.unique (
          lib.concatMap (
            e:
            # the packages of environments that work on the host
            lib.optionals (!(e.fhs or false)) (e.packages ++ e.hostOnlyPackages or [ ])
            # and the shells of the ones that need the layout
            ++ lib.optional e.needsFhs e.shell
          ) self.closure
        );
      };
    in
    self;
}
