# A NixOS container used by the nixosConfigurations in flake.nix, with the
# user from create_user.sh.
{ ... }:

{
  imports = [ ./module.nix ];

  boot.isContainer = true;

  # useradd --uid 30000 --create-home build
  # gid 30000 is taken by the nixbld group on NixOS
  users.groups.build = { };
  users.users.build = {
    isNormalUser = true;
    uid = 30000;
    group = "build";
    # no password, like useradd without -p
    hashedPassword = "!";
  };

  # build ALL=(ALL) NOPASSWD: ALL
  security.sudo.extraRules = [
    {
      users = [ "build" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "26.05";
}
