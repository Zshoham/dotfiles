# The `environments` option: sets of packages that can include each other,
# each with a shell of its own. Every file in environments/ is a module that
# defines some of them.
#
# A shell has everything of the environments in its closure (the
# environment and everything it includes). It's bash in a buildFHSEnv, a
# regular Linux layout (/lib64/ld-linux..., /usr/lib) for what needs it.
{
  lib,
  buildEnv,
  buildFHSEnv,
  glibcLocales,
  writeText,
  writeShellScript,
}:

{ config, ... }:

let
  inherit (lib) mkOption types;
  environments = config.environments;

  # names, depth first, included environments before the ones including
  # them, every environment once
  closureOf = name: lib.unique (lib.concatMap closureOf environments.${name}.includes ++ [ name ]);

  mkShell =
    { name, closure }:
    let
      # sourced by every shell, interactive or not
      init = writeText "${name}-init" (
        ''
          unset BASH_ENV
          case $- in *i*) PS1="(${name}) $PS1" ;; esac
        ''
        + lib.concatMapStrings (env: env.init) closure
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
      profile = ''
        export LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive
      ''
      + lib.concatMapStrings (env: env.profile) closure;
      runScript = writeShellScript name ''
        # non-interactive shells (`${name} -c ...`) get the setup through BASH_ENV
        if [ $# -gt 0 ]; then
          export BASH_ENV=${init}
        fi
        exec bash --rcfile ${bashrc} "$@"
      '';
    };

  environment =
    { name, config, ... }:
    {
      options = {
        name = mkOption {
          type = types.str;
          default = name;
          readOnly = true;
          description = "The name of the environment and its shell.";
        };
        packages = mkOption {
          type = types.listOf types.package;
          default = [ ];
          description = "The packages of the environment.";
        };
        includes = mkOption {
          type = types.listOf (types.enum (lib.attrNames environments));
          default = [ ];
          description = "Environments it includes, with everything they include.";
        };
        fhs = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Whether its packages need a regular Linux layout to work, e.g.
            prebuilt binaries. They are then only installed in its shell.
          '';
        };
        profile = mkOption {
          type = types.lines;
          default = "";
          description = "Environment variables of its shell.";
        };
        init = mkOption {
          type = types.lines;
          default = "";
          description = "Bash setup of its shell, after ~/.bashrc.";
        };
        hostOnlyPackages = mkOption {
          type = types.listOf types.package;
          default = [ ];
          description = "Packages only installed on the host, not in its shell.";
        };
        nixos = mkOption {
          type = types.attrsOf types.anything;
          default = { };
          description = ''
            NixOS configuration (services, programs, ...) applied when it or
            an environment including it is enabled in the NixOS module.
          '';
        };

        closure = mkOption {
          type = types.listOf types.raw;
          readOnly = true;
          description = "The environment and everything it includes, each once.";
        };
        needsFhs = mkOption {
          type = types.bool;
          readOnly = true;
          description = "Whether it or something it includes needs the layout.";
        };
        shell = mkOption {
          type = types.package;
          readOnly = true;
          description = "A shell with everything of its closure.";
        };
        hostPackages = mkOption {
          type = types.listOf types.package;
          readOnly = true;
          description = ''
            What installs it on a host: the packages of the environments in
            its closure that work on the host, and the shells of the ones
            that need the layout.
          '';
        };
        package = mkOption {
          type = types.package;
          readOnly = true;
          description = ''
            The environment as one package: its shell if it needs the layout,
            otherwise its host packages.
          '';
        };
      };

      config = {
        closure = map (n: environments.${n}) (closureOf name);
        needsFhs = lib.any (env: env.fhs) config.closure;
        shell = mkShell {
          inherit name;
          inherit (config) closure;
        };
        hostPackages = lib.unique (
          lib.concatMap (
            env:
            lib.optionals (!env.fhs) (env.packages ++ env.hostOnlyPackages)
            ++ lib.optional env.needsFhs env.shell
          ) config.closure
        );
        package =
          if config.needsFhs then
            config.shell
          else
            buildEnv {
              inherit name;
              paths = config.hostPackages;
            };
      };
    };
in
{
  options.environments = mkOption {
    type = types.attrsOf (types.submodule environment);
    default = { };
    description = "The environments, by name.";
  };
}
