local function update_lsp()
  local to_update = require("mason-lspconfig.settings").current.ensure_installed
  require("mason-lspconfig.api.command").LspInstall(to_update)
end

local function update_mason()
  -- current.ensure_installed is a lazyvim extention.
  local to_update = require("mason.settings").current.ensure_installed
  require("mason-registry").update()
  require("mason.api.command").MasonInstall(to_update)
end

local function update_plugins()
  require("lazy").update({ wait = true, show = false })
end

local function update_treesitter()
  -- we wait a maximum of 5 minutes for the update.
  require("nvim-treesitter").update():wait(300000)
end

local function update_blink()
  local download_done = false
  local download_result = {}

  local function download_cb(err, implementation)
    download_result.err = err
    download_result.implementation = implementation
    download_done = true
  end
  require("blink.cmp.fuzzy.download").ensure_downloaded(download_cb)

  vim.wait(60000, function()
    return download_done
  end)

  if not download_done then
    vim.notify("Blink download timed out!", vim.log.levels.ERROR)
    return
  end

  print("Blink download finished!")
  if download_result.err then
    print("Blink download failed:", download_result.err)
  else
    print("Blink download succeeded. Implementation:", download_result.implementation)
  end
end

local function update_all()
  update_plugins()
  update_treesitter()
  update_lsp()
  update_mason()
  update_blink()
end

return {
  update_plugins = update_plugins,
  update_treesitter = update_treesitter,
  update_lsp = update_lsp,
  update_mason = update_mason,
  update_blink = update_blink,
  update_all = update_all,
}
