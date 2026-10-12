# gitlab.nvim with its Go server, built from the same source.
{
  lib,
  buildGoModule,
  fetchFromGitHub,
  vimUtils,
}:

let
  version = "3.4.1-unstable-2026-06-09";

  src = fetchFromGitHub {
    owner = "harrisoncramer";
    repo = "gitlab.nvim";
    rev = "2295d1e85c5e4d79c49cadda36b9848a3ffed4e2";
    hash = "sha256-J2yljPEWjFQf5XOm1VwlZSqvVhP4VO/k9nrzdmXEMG0=";
  };

  server = buildGoModule {
    pname = "gitlab-nvim-server";
    inherit version src;
    vendorHash = "sha256-OLAKTdzqynBDHqWV5RzIpfc3xZDm6uYyLD4rxbh0DMg=";
    subPackages = [ "cmd" ];
    ldflags = [ "-X main.Version=${version}" ];
    postInstall = ''
      mv $out/bin/cmd $out/bin/gitlab-nvim-server
    '';
  };
in
vimUtils.buildVimPlugin {
  pname = "gitlab.nvim";
  inherit version src;
  doCheck = false;
  passthru = { inherit server; };
  meta = {
    description = "Review GitLab merge requests in neovim";
    homepage = "https://github.com/harrisoncramer/gitlab.nvim";
    license = lib.licenses.mit;
  };
}
