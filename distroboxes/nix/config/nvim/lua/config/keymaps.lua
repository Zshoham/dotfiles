-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "<c-x>", "<esc>", { silent = true, desc = "Enter normal mode." })
vim.keymap.set("n", "<leader>gv", "<cmd>DiffviewOpen<cr>", { silent = true, desc = "Open Git DiffView" })
