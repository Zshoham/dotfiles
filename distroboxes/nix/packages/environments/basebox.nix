# The basebox: the programs of Dockerfile.basebox.
{
  pkgs,
  groups,
  programs,
  ...
}:

{
  environments.basebox = {
    packages = with groups; base ++ utils ++ buildTools ++ shell ++ languages ++ [ pkgs.gcc ];

    nixos = {
      programs.fish = {
        enable = true;
        package = programs.fish;
      };
      # words
      environment.pathsToLink = [ "/share/dict" ];
      documentation.dev.enable = true;
    };
  };
}
