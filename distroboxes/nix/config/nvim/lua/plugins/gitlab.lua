return {
  {
    "harrisoncramer/gitlab.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "dlyongemallo/diffview.nvim", -- Maintained fork of "sindrets/diffview.nvim".
    },
    config = function()
      -- the server is built by nix
      require("gitlab").setup({ server = { binary = "@gitlab_server@" } })
    end,
  },
}
