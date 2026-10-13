return {
  { "stevearc/quicker.nvim" },
  { "HiPhish/rainbow-delimiters.nvim" },
  { "nvim-mini/mini.align", version = false },
  { "nvim-mini/mini.surround", version = false },
  { "nvim-mini/mini.splitjoin", version = false },
  { "nvim-mini/mini.operators", version = false },
  { "saghen/blink.cmp", opts = { fuzzy = { implementation = "rust" } } },
  { "dlyongemallo/diffview.nvim", dependencies = "nvim-lua/plenary.nvim" },
  { "nvim-treesitter/nvim-treesitter-context", opts = { separator = "─", max_lines = 2 } },
  {
    "stevearc/oil.nvim",
    lazy = false,
    config = function ()
      require("oil").setup()
    end,
    keys = {
      { "<leader>o", "<cmd>Oil --float .<cr>", desc = "Open oil explorer"}
    }
  },
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
  {
    "chrisgrieser/nvim-spider",
    keys = {
      {
        "w",
        function()
          require("spider").motion("w")
        end,
        mode = { "n", "o", "x" },
      },
      {
        "e",
        function()
          require("spider").motion("e")
        end,
        mode = { "n", "o", "x" },
      },
      {
        "b",
        function()
          require("spider").motion("b")
        end,
        mode = { "n", "o", "x" },
      },
      {
        "ge",
        function()
          require("spider").motion("ge")
        end,
        mode = { "n", "o", "x" },
      },
    },
  },
  {
    "2kabhishek/seeker.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = { "Seeker" },
    keys = {
      {
        "<leader>fs",
        function()
          require("seeker").seek({ mode = "files" })
        end,
        desc = "Seek files progressively",
      },
      {
        "<leader>fa",
        function()
          require("seeker").seek({ mode = "git_files" })
        end,
        desc = "Seek git files progressively",
      },
    },
  },
}
