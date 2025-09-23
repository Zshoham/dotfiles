return {
  { "sindrets/diffview.nvim", dependencies = "nvim-lua/plenary.nvim" },
  { "HiPhish/rainbow-delimiters.nvim" },
  { "nvim-treesitter/nvim-treesitter-context", opts = { separator = "─", max_lines = 2 } },
  { "saghen/blink.cmp", opts = { fuzzy = { implementation = "rust" } } },
  {
    "rmagatti/goto-preview",
    lazy = false,
    opts = {
      default_mappings = true,
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      statuscolumn = { folds = { open = true } },
    },
  },
}
