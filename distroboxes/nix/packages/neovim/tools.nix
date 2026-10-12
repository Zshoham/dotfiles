# The nixpkgs package for each tool the neovim config installs with mason
# (the "mason" list in its external.json).
pkgs: with pkgs; {
  "bash-language-server" = bash-language-server;
  "clangd" = clang-tools;
  "cmakelang" = cmake-format;
  "cmakelint" = cmake-lint;
  "docker-compose-language-service" = docker-compose-language-service;
  "dockerfile-language-server" = dockerfile-language-server;
  "hadolint" = hadolint;
  "json-lsp" = vscode-langservers-extracted;
  "lua-language-server" = lua-language-server;
  "markdown-toc" = markdown-toc;
  "markdownlint-cli2" = markdownlint-cli2;
  "marksman" = marksman;
  "neocmakelsp" = neocmakelsp;
  "ruff" = ruff;
  "shfmt" = shfmt;
  "sqlfluff" = sqlfluff;
  "stylua" = stylua;
  "taplo" = taplo;
  "tinymist" = tinymist;
  "tree-sitter-cli" = tree-sitter;
  "ty" = ty;
  "yaml-language-server" = yaml-language-server;
}
