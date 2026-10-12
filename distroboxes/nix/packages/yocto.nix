# An environment for building with yocto, replacing the buildtools-extended
# SDK of the workbox image. The toolchain matches buildtools-extended 4.3
# (gcc 13), with python 3.12, the FHS layout keeps bitbake's host tool
# checks happy.
#
#   yocto                      # bash in the yocto environment
#   yocto -c 'bitbake ...'
{
  lib,
  buildFHSEnv,
  glibcLocales,
  runCommand,
  pkgs,
  groups,
}:

buildFHSEnv {
  name = "yocto";

  targetPkgs =
    _:
    groups.base
    ++ groups.utils
    ++ groups.buildTools
    ++ (with pkgs; [
      # the buildtools-extended toolchain
      gcc13
      (python312.withPackages (
        ps: with ps; [
          gitpython
          jinja2
          pexpect
          python-subunit
        ]
      ))

      # host packages from the yocto docs and yocto.sh
      acl
      chrpath
      cpio
      debianutils
      diffstat
      lz4
      # yocto 4.3 still checks for the old lz4c name
      (runCommand "lz4c" { } "mkdir -p $out/bin; ln -s ${lib.getBin lz4}/bin/lz4 $out/bin/lz4c")
      ncurses
      openssl
      rpcsvc-proto
      socat
      texinfo
      zlib
    ]);

  profile = ''
    export LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive
    export LANG=en_US.UTF-8
    export PS1="(yocto) $PS1"
  '';

  runScript = "bash";
}
