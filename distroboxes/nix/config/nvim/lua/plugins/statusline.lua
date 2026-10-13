return {
  {
    "SmiteshP/nvim-navic",
    opts = {
      separator = " 🞂 ",
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        -- set an empty statusline till lualine loads
        vim.o.statusline = " "
      else
        -- hide the statusline on the starter page
        vim.o.laststatus = 0
      end
    end,
    opts = function(_, opts)
      local icons = LazyVim.config.icons

      vim.o.laststatus = vim.g.lualine_laststatus
      opts.options.section_separators = " "
      opts.options.component_separators = "  "

      local winbar_config = {
        lualine_c = {
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          {
            "filename",
            path = 1,
            symbols = { modified = icons.git.modified, readonly = "", unnamed = "" },
          },
        },
      }

      opts.winbar = winbar_config
      opts.inactive_winbar = winbar_config

      local lazy_rootdir = LazyVim.lualine.root_dir()
      lazy_rootdir.separator = "|>"

      opts.sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },

        lualine_c = {
          lazy_rootdir,
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          {
            "filename",
            path = 0,
            separator = "|>",
            symbols = { modified = icons.git.modified, readonly = "", unnamed = "" },
          },
          {
            function()
              return require("nvim-navic").get_location()
            end,
            cond = function()
              return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
            end,
          },
        },
        lualine_x = {
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = function()
              return { fg = Snacks.util.color("Special") }
            end,
          },
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
        -- stylua: ignore
        {
          function() return require("noice").api.status.mode.get() end,
          cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
          color = function() return { fg = Snacks.util.color("Constant") } end,
        },
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
          },
        },
        lualine_y = {
          { "location", padding = { left = 1, right = 0 } },
        },
        lualine_z = { "hostname" },
      }

      return opts
    end,
  },
}
