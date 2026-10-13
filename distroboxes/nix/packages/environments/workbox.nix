# The workbox: the programs of Dockerfile.work, with the basebox and the
# yocto and conda environments.
{
  lib,
  pkgs,
  groups,
  environments,
}:

{
  name = "workbox";
  includes = with environments; [
    basebox
    yocto
    conda
  ];
  packages = with groups; debug ++ work ++ groups.yocto;
  # multilib-devel, on the host, the shell keeps yocto's gcc 13
  hostOnlyPackages = [ (lib.hiPrio pkgs.gcc_multi) ];
}
