# The plugins of the neovim config by their lazy.nvim name, from nixpkgs
# where it has them. lazy.nvim loads them from a directory with one entry
# per name (dev.path in the config).
{
  lib,
  vimPlugins,
  vimUtils,
  fetchFromGitHub,
  callPackage,
}:

let
  # plugins nixpkgs doesn't have (or has from another repo)
  diffview-nvim = vimUtils.buildVimPlugin {
    pname = "diffview.nvim";
    version = "0-unstable-2026-06-23";
    # maintained fork of sindrets/diffview.nvim
    src = fetchFromGitHub {
      owner = "dlyongemallo";
      repo = "diffview.nvim";
      rev = "d5c09986681a671613aef0226ef409c01561d64c";
      hash = "sha256-M3fJ9qZuU/c7EnQeABp09Kznj5soPZwAGRhPaTxZfag=";
    };
    dependencies = [ vimPlugins.plenary-nvim ];
  };

  seeker-nvim = vimUtils.buildVimPlugin {
    pname = "seeker.nvim";
    version = "0-unstable-2026-02-10";
    src = fetchFromGitHub {
      owner = "2kabhishek";
      repo = "seeker.nvim";
      rev = "c0ec94116bb6c603ad5780bc433cb09b8ae84041";
      hash = "sha256-sITiKTeP7G2GRiYTSqJCgSEe2/lk1nyz1xl25zE2Knk=";
    };
    dependencies = [ vimPlugins.snacks-nvim ];
  };

  gitlab-nvim = callPackage ./gitlab-nvim.nix { };
in
with vimPlugins;
{
  "LazyVim" = LazyVim;
  "SchemaStore.nvim" = SchemaStore-nvim;
  "blink.cmp" = blink-cmp;
  "bufferline.nvim" = bufferline-nvim;
  "catppuccin" = catppuccin-nvim;
  "clangd_extensions.nvim" = clangd_extensions-nvim;
  "cmake-tools.nvim" = cmake-tools-nvim;
  "conform.nvim" = conform-nvim;
  "crates.nvim" = crates-nvim;
  "diffview.nvim" = diffview-nvim;
  "flash.nvim" = flash-nvim;
  "friendly-snippets" = friendly-snippets;
  "gitlab.nvim" = gitlab-nvim;
  "gitsigns.nvim" = gitsigns-nvim;
  "goto-preview" = goto-preview;
  "grug-far.nvim" = grug-far-nvim;
  "inc-rename.nvim" = inc-rename-nvim;
  "lazydev.nvim" = lazydev-nvim;
  "lualine.nvim" = lualine-nvim;
  "markdown-preview.nvim" = markdown-preview-nvim;
  "mini.ai" = mini-ai;
  "mini.align" = mini-align;
  "mini.hipatterns" = mini-hipatterns;
  "mini.icons" = mini-icons;
  "mini.operators" = mini-operators;
  "mini.pairs" = mini-pairs;
  "mini.splitjoin" = mini-splitjoin;
  "mini.surround" = mini-surround;
  "multicursor.nvim" = multicursor-nvim;
  "noice.nvim" = noice-nvim;
  "nui.nvim" = nui-nvim;
  "nvim-lint" = nvim-lint;
  "nvim-lspconfig" = nvim-lspconfig;
  "nvim-navic" = nvim-navic;
  "nvim-spider" = nvim-spider;
  "nvim-treesitter" = nvim-treesitter;
  "nvim-treesitter-context" = nvim-treesitter-context;
  "nvim-treesitter-textobjects" = nvim-treesitter-textobjects;
  "nvim-ts-autotag" = nvim-ts-autotag;
  "oil.nvim" = oil-nvim;
  "persistence.nvim" = persistence-nvim;
  "plenary.nvim" = plenary-nvim;
  "quicker.nvim" = quicker-nvim;
  "rainbow-delimiters.nvim" = rainbow-delimiters-nvim;
  "render-markdown.nvim" = render-markdown-nvim;
  "rustaceanvim" = rustaceanvim;
  "seeker.nvim" = seeker-nvim;
  "snacks.nvim" = snacks-nvim;
  "todo-comments.nvim" = todo-comments-nvim;
  "tokyonight.nvim" = tokyonight-nvim;
  "trouble.nvim" = trouble-nvim;
  "ts-comments.nvim" = ts-comments-nvim;
  "venv-selector.nvim" = venv-selector-nvim;
  "vim-dadbod" = vim-dadbod;
  "vim-dadbod-completion" = vim-dadbod-completion;
  "vim-dadbod-ui" = vim-dadbod-ui;
  "which-key.nvim" = which-key-nvim;
}
