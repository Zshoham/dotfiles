# The basebox: the programs of Dockerfile.basebox.
{ pkgs, groups, ... }:

{
  environments.basebox.packages =
    with groups;
    base ++ utils ++ buildTools ++ shell ++ languages ++ [ pkgs.gcc ];
}
