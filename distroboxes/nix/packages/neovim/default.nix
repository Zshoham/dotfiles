# neovim with the external dependencies of the neovim config
# (github:Zshoham/neovim) from nix: the tools it installs with mason on
# PATH, and the tree-sitter parsers and plugins with native code prebuilt.
# The config finds them through vim.g.nix (lua/plugins/nix.lua there).
{
  lib,
  pkgs,
  wrappers,
  nvim-config,
}:

let
  external = lib.importJSON "${nvim-config}/external.json";

  tools =
    let
      available = import ./tools.nix pkgs;
    in
    map (
      name:
      available.${name}
        or (throw "neovim: no nix package for the mason tool `${name}`, add it to packages/neovim/tools.nix")
    ) external.mason;

  # An nvim-treesitter install directory (parser/ and queries/) with the
  # parsers and queries of every language in the list.
  treesitter =
    let
      ts = pkgs.vimPlugins.nvim-treesitter;
      # queries can depend on the queries of other languages (tsx -> ecma)
      queriesOf =
        lang:
        let
          query = ts.queries.${lang};
        in
        [ query ] ++ lib.concatMap (dep: queriesOf dep.language) (query.passthru.dependencies or [ ]);
      langPaths =
        lang:
        assert lib.assertMsg (ts.parsers ? ${lang} || ts.queries ? ${lang})
          "neovim: nvim-treesitter has no parser or queries for `${lang}`";
        lib.optional (ts.parsers ? ${lang}) ts.parsers.${lang}
        ++ lib.optionals (ts.queries ? ${lang}) (queriesOf lang);
    in
    pkgs.symlinkJoin {
      name = "nvim-treesitter-install";
      paths = lib.unique (lib.concatMap langPaths external.treesitter);
    };

  gitlab-nvim = pkgs.callPackage ./gitlab-nvim.nix { };

  nix = {
    inherit treesitter;
    plugins = {
      "nvim-treesitter" = pkgs.vimPlugins.nvim-treesitter;
      "blink.cmp" = pkgs.vimPlugins.blink-cmp;
      "markdown-preview.nvim" = pkgs.vimPlugins.markdown-preview-nvim;
      "gitlab.nvim" = gitlab-nvim;
    };
    gitlab_server = lib.getExe' gitlab-nvim.server "gitlab-nvim-server";
  };
in
wrappers.lib.wrapPackage {
  inherit pkgs;
  package = pkgs.neovim;
  runtimeInputs = tools;
  flags."--cmd" = "lua vim.g.nix = ${lib.generators.toLua { multiline = false; } nix}";
  passthru = { inherit treesitter tools; };
}
