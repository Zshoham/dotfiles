return {
  -- the parsers and queries are installed by nix
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.install_dir = "@treesitter@"
      opts.ensure_installed = {}
    end,
  },
  -- language servers and tools are on PATH, installed by nix
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- not configured by a LazyVim extra
        tinymist = {},
      },
    },
  },
}
