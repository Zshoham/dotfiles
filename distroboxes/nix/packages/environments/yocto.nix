# The yocto environment, replacing the buildtools-extended SDK of the
# workbox image. The toolchain matches buildtools-extended 4.3 (gcc 13),
# with python 3.12, the FHS layout keeps bitbake's host tool checks happy.
{
  lib,
  glibcLocales,
  runCommand,
  pkgs,
  groups,
}:

{
  name = "yocto";
  fhs = true;

  packages =
    groups.base
    ++ groups.utils
    ++ groups.buildTools
    ++ groups.yocto
    ++ (with pkgs; [
      # the buildtools-extended toolchain, preferred over the gcc and python
      # of environments it is combined with (basebox)
      (lib.hiPrio gcc13)
      (lib.hiPrio (
        python312.withPackages (
          ps: with ps; [
            gitpython
            jinja2
            pexpect
            python-subunit
          ]
        )
      ))

      # other host packages from the yocto docs
      acl
      debianutils
      lz4
      # yocto 4.3 still checks for the old lz4c name
      (runCommand "lz4c" { } "mkdir -p $out/bin; ln -s ${lib.getBin lz4}/bin/lz4 $out/bin/lz4c")
      openssl
      socat
      zlib
    ]);

  profile = ''
    export LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive
    export LANG=en_US.UTF-8
  '';
}
