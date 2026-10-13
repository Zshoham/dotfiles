# neovim with its whole configuration from config/nvim (LazyVim): the
# plugins, the tree-sitter parsers and queries, and the language servers and
# tools all come from nix, nothing is downloaded or built at runtime.
{
  lib,
  pkgs,
  wrappers,
}:

let
  # The language servers and tools, commented with their mason name.
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

  # The tree-sitter parsers of the config. ecma and jsx only have queries,
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

  plugins = lib.filterAttrs (_: lib.isDerivation) (pkgs.callPackage ./plugins.nix { });

  # lazy.nvim loads the plugins from here (dev.path in the config)
  pluginsDir = pkgs.linkFarm "nvim-plugins" plugins;

  config = pkgs.runCommand "nvim-config" { } ''
    cp -r ${../../config/nvim} $out
    chmod -R u+w $out
    substituteInPlace $(grep -rl '@[a-z_]*@' $out) \
      --replace-quiet @config@ $out \
      --replace-quiet @lazy@ ${pkgs.vimPlugins.lazy-nvim} \
      --replace-quiet @plugins@ ${pluginsDir} \
      --replace-quiet @treesitter@ ${treesitter} \
      --replace-quiet @gitlab_server@ ${lib.getExe' plugins."gitlab.nvim".server "gitlab-nvim-server"}
    if grep -rn '@[a-z_]*@' $out; then
      echo "unreplaced placeholders in the neovim config"
      exit 1
    fi
  '';
in
wrappers.lib.wrapPackage {
  inherit pkgs;
  package = pkgs.neovim;
  runtimeInputs = tools;
  flags."-u" = "${config}/init.lua";
  passthru = {
    inherit
      config
      plugins
      tools
      treesitter
      ;
  };
}
