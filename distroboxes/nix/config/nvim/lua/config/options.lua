-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local vim = vim

vim.g.autoformat = false
vim.opt.pumblend = 0 -- Enables pseudo-transparency for the popup-menu
vim.o.winborder = "rounded"

vim.g.lazyvim_python_lsp = "ty"
vim.g.lazyvim_python_ruff = "ruff"
