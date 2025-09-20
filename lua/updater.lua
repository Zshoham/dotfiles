local function update_mason()
  local to_update = require("mason.settings").current.ensure_installed
  require("mason-registry").update()
  require("mason.api.command").MasonInstall(to_update)
end

return {
  update_mason = update_mason
}
