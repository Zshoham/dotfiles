# neovim with the external dependencies of the neovim config
# (github:Zshoham/neovim), which it otherwise installs itself:
# - the tools installed with mason, on neovim's PATH
# - the tree-sitter parsers and queries
# - the plugins that download or build native code
# The config finds them through vim.g.nix (lua/plugins/nix.lua there) and
# then doesn't use mason, so nothing prebuilt is downloaded.
{
  lib,
  pkgs,
  wrappers,
}:

let
  # The mason list of the config, by mason name.
  tools = with pkgs; [
    bash-language-server # bash-language-server
    clang-tools # clangd
    cmake-format # cmakelang
    cmake-lint # cmakelint
    docker-compose-language-service # docker-compose-language-service
    dockerfile-language-server # dockerfile-language-server
    hadolint # hadolint
    lua-language-server # lua-language-server
    markdown-toc # markdown-toc
    markdownlint-cli2 # markdownlint-cli2
    marksman # marksman
    neocmakelsp # neocmakelsp
    ruff # ruff
    shfmt # shfmt
    sqlfluff # sqlfluff
    stylua # stylua
    taplo # taplo
    tinymist # tinymist
    tree-sitter # tree-sitter-cli
    ty # ty
    vscode-langservers-extracted # json-lsp
    yaml-language-server # yaml-language-server
  ];

  # The tree-sitter list of the config. ecma and jsx only have queries,
  # jsonc is not an nvim-treesitter language anymore.
  languages = [
    "bash"
    "bitbake"
    "c"
    "cmake"
    "cpp"
    "cuda"
    "devicetree"
    "diff"
    "dockerfile"
    "ecma"
    "fish"
    "git_config"
    "git_rebase"
    "gitattributes"
    "gitcommit"
    "gitignore"
    "html"
    "hyprlang"
    "javascript"
    "jsdoc"
    "json"
    "json5"
    "jsx"
    "just"
    "kconfig"
    "lua"
    "luadoc"
    "luap"
    "make"
    "markdown"
    "markdown_inline"
    "ninja"
    "printf"
    "python"
    "query"
    "rasi"
    "regex"
    "rst"
    "rust"
    "sql"
    "toml"
    "tsx"
    "typescript"
    "typst"
    "vim"
    "vimdoc"
    "xml"
    "yaml"
  ];

  # parser/ and queries/ for every language, from nixpkgs' nvim-treesitter
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
        assert lib.assertMsg (
          ts.parsers ? ${lang} || ts.queries ? ${lang}
        ) "neovim: nvim-treesitter has no parser or queries for `${lang}`";
        lib.optional (ts.parsers ? ${lang}) ts.parsers.${lang}
        ++ lib.optionals (ts.queries ? ${lang}) (queriesOf lang);
    in
    pkgs.symlinkJoin {
      name = "nvim-treesitter-parsers";
      paths = lib.unique (lib.concatMap langPaths languages);
    };

  gitlab-nvim = pkgs.callPackage ./gitlab-nvim.nix { };

  nix = {
    # an nvim-treesitter install directory, parser/ and queries/
    inherit treesitter;
    plugins = {
      # the same version as the queries
      "nvim-treesitter" = pkgs.vimPlugins.nvim-treesitter;
      # with its rust fuzzy matcher
      "blink.cmp" = pkgs.vimPlugins.blink-cmp;
      # with its app
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
  passthru = { inherit tools treesitter; };
}
