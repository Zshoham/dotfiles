# A shell for yocto builds, replacing the buildtools-extended SDK the
# workbox image installs to /opt/yoctoenv. The toolchain matches the one in
# buildtools-extended 4.3 (gcc 13), with python 3.12, the FHS layout keeps
# bitbake's host tool checks happy.
#
#   yocto                      # bash in the yocto environment
#   yocto -c 'bitbake ...'
{ buildFHSEnv, pkgs }:

buildFHSEnv {
  name = "yocto";

  targetPkgs =
    pkgs: with pkgs; [
      # buildtools-extended
      gcc13
      gnumake
      (python312.withPackages (
        ps: with ps; [
          gitpython
          jinja2
          pexpect
          python-subunit
        ]
      ))
      git
      gnutar
      perl

      # host packages from the yocto docs and yocto.sh
      acl
      bash
      bzip2
      chrpath
      coreutils
      cpio
      debianutils
      diffstat
      diffutils
      file
      findutils
      gawk
      gnugrep
      gnused
      gzip
      hostname
      iputils
      lz4
      # yocto 4.3 still checks for the old lz4c name
      (runCommand "lz4c" { } "mkdir -p $out/bin; ln -s ${lib.getBin lz4}/bin/lz4 $out/bin/lz4c")
      ncurses
      openssl
      patch
      procps
      rpcsvc-proto
      rsync
      socat
      texinfo
      unzip
      util-linux
      wget
      which
      xz
      zlib
      zstd
    ];

  profile = ''
    export LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive
    export LANG=en_US.UTF-8
    export PS1="(yocto) $PS1"
  '';

  runScript = "bash";
}
