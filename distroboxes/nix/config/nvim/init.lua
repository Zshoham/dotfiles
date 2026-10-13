-- This config is built by nix (packages/neovim), which fills in the @...@
-- paths, and neovim is started with it instead of the one in
-- stdpath("config"). Make it the config on the runtimepath.
local config = "@config@"
local user_config = vim.fn.stdpath("config")
vim.opt.rtp:remove({ user_config, user_config .. "/after" })
vim.opt.rtp:prepend(config)
vim.opt.rtp:append(config .. "/after")
vim.g.lazyvim_json = config .. "/lazyvim.json"

require("config.lazy")
