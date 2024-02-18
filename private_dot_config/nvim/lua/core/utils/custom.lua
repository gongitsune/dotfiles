local M = {}

--- Looks to see if a module path references a lua file in a configuration folder and tries to load it. If there is an error loading the file, write an error and continue
---@param module string The module path to try and load
---@return table|nil # The loaded module if successful or nil
local function load_module_file(module)
  -- placeholder for final return value
  local found_file = nil
  -- search through each of the supported configuration locations
  for _, config_path in ipairs(M.supported_configs) do
    -- convert the module path to a file path (example user.init -> user/init.lua)
    local module_path = config_path .. "/lua/" .. module:gsub("%.", "/") .. ".lua"
    -- check if there is a readable file, if so, set it as found
    if vim.fn.filereadable(module_path) == 1 then found_file = module_path end
  end
  -- if we found a readable lua file, try to load it
  local out = nil
  if found_file then
    -- try to load the file
    local status_ok, loaded_module = pcall(require, module)
    -- if successful at loading, set the return variable
    if status_ok then
      out = loaded_module
      -- if unsuccessful, throw an error
    else
      vim.api.nvim_err_writeln("Error loading file: " .. found_file .. "\n\n" .. loaded_module)
    end
  end
  -- return the loaded module or nil if no file found
  return out
end

--- Main configuration engine logic for extending a default configuration table with either a function override or a table to merge into the default option
-- @param overrides the override definition, either a table or a function that takes a single parameter of the original table
-- @param default the default configuration table
-- @param extend boolean value to either extend the default or simply overwrite it if an override is provided
-- @return the new configuration table
local function func_or_extend(overrides, default, extend)
  -- if we want to extend the default with the provided override
  if extend then
    -- if the override is a table, use vim.tbl_deep_extend
    if type(overrides) == "table" then
      local opts = overrides or {}
      default = default and vim.tbl_deep_extend("force", default, opts) or opts
      -- if the override is  a function, call it with the default and overwrite default with the return value
    elseif type(overrides) == "function" then
      default = overrides(default)
    end
    -- if extend is set to false and we have a provided override, simply override the default
  elseif overrides ~= nil then
    default = overrides
  end
  -- return the modified default table
  return default
end

--- User configuration entry point to override the default options of a configuration table with a user configuration file or table in the user/init.lua user settings
---@param module string The module path of the override setting
---@param default? any The default value that will be overridden
---@param extend? boolean # Whether extend the default settings or overwrite them with the user settings entirely (default: true)
---@return any # The new configuration settings with the user overrides applied
function M.user_opts(module, default, extend)
  -- default to extend = true
  if extend == nil then extend = true end
  -- if no default table is provided set it to an empty table
  if default == nil then default = {} end
  -- try to load a module file if it exists
  local user_module_settings = load_module_file("custom." .. module)
  -- if a user override was found call the configuration engine
  if user_module_settings ~= nil then default = func_or_extend(user_module_settings, default, extend) end
  -- return the final configuration table with any overrides applied
  return default
end

M.supported_configs = {
  vim.fn.stdpath "config"
}
M.lsp = { skip_setup = M.user_opts("lsp.skip_setup", {}), progress = {} }

return M
