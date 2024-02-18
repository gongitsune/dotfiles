local custom = require "core.utils.custom"
local utils = require "core.utils"
local user_opts = custom.user_opts
local conditional_func = utils.conditional_func
local extend_tbl = utils.extend_tbl

local M = {}

local server_config = "lsp.config."
local setup_handlers = {
  function(server, opts)
    require("lspconfig")[server].setup(opts)
  end,
}

M.diagnostics = { [0] = {}, {}, {}, {} }

M.setup_diagnostics = function(signs)
  local default_diagnostics = {
    virtual_text = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = utils.get_icon "DiagnosticError",
        [vim.diagnostic.severity.HINT] = utils.get_icon "DiagnosticHint",
        [vim.diagnostic.severity.WARN] = utils.get_icon "DiagnosticWarn",
        [vim.diagnostic.severity.INFO] = utils.get_icon "DiagnosticInfo",
      },
      active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focused = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }
  M.diagnostics = {
    -- diagnostics off
    [0] = extend_tbl(
      default_diagnostics,
      { underline = false, virtual_text = false, signs = false, update_in_insert = false }
    ),
    -- status only
    extend_tbl(default_diagnostics, { virtual_text = false, signs = false }),
    -- virtual text off, signs on
    extend_tbl(default_diagnostics, { virtual_text = false }),
    -- all diagnostics on
    default_diagnostics,
  }

  vim.diagnostic.config(M.diagnostics[vim.g.diagnostics_mode])
end

--- Helper function to set up a given server with the Neovim LSP client
---@param server string The name of the server to be setup
M.setup = function(server)
  -- if server doesn't exist, set it up from user server definition
  local config_avail, config = pcall(require, "lspconfig.server_configurations." .. server)
  if not config_avail or not config.default_config then
    local server_definition = custom.user_opts(server_config .. server)
    if server_definition.cmd then require("lspconfig.configs")[server] = { default_config = server_definition } end
  end
  local opts = M.config(server)
  local setup_handler = setup_handlers[server] or setup_handlers[1]
  if not vim.tbl_contains(custom.lsp.skip_setup, server) and setup_handler then
    setup_handler(server, opts)
  end
end

--- The default AstroNvim LSP capabilities
M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem.documentationFormat = { "markdown", "plaintext" }
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities.textDocument.completion.completionItem.preselectSupport = true
M.capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
M.capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
M.capabilities.textDocument.completion.completionItem.deprecatedSupport = true
M.capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
M.capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
M.capabilities.textDocument.completion.completionItem.resolveSupport =
{ properties = { "documentation", "detail", "additionalTextEdits" } }
M.capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
M.capabilities = user_opts("lsp.capabilities", M.capabilities)
M.flags = user_opts "lsp.flags"

--- Get the server configuration for a given language server to be provided to the server's `setup()` call
---@param server_name string The name of the server
---@return table # The table of LSP options used when setting up the given language server
function M.config(server_name)
  local server = require("lspconfig")[server_name]
  local lsp_opts = extend_tbl(server, { capabilities = M.capabilities, flags = M.flags })
  if server_name == "jsonls" then -- by default add json schemas
    local schemastore_avail, schemastore = pcall(require, "schemastore")
    if schemastore_avail then
      lsp_opts.settings = { json = { schemas = schemastore.json.schemas(), validate = { enable = true } } }
    end
  end
  if server_name == "yamlls" then -- by default add yaml schemas
    local schemastore_avail, schemastore = pcall(require, "schemastore")
    if schemastore_avail then lsp_opts.settings = { yaml = { schemas = schemastore.yaml.schemas() } } end
  end
  if server_name == "lua_ls" then -- by default initialize neodev and disable third party checking
    pcall(require, "neodev")
    lsp_opts.before_init = function(param, config)
      if vim.b.neodev_enabled then
        for _, astronvim_config in ipairs(custom.supported_configs) do
          if param.rootPath:match(astronvim_config) then
            table.insert(config.settings.Lua.workspace.library, vim.fn.stdpath("config") .. "/lua")
            break
          end
        end
      end
    end
    lsp_opts.settings = { Lua = { workspace = { checkThirdParty = false } } }
  end
  local opts = user_opts(server_config .. server_name, lsp_opts)
  local old_on_attach = server.on_attach
  local user_on_attach = opts.on_attach
  opts.on_attach = function(client, bufnr)
    conditional_func(old_on_attach, true, client, bufnr)
    M.on_attach(client, bufnr)
    conditional_func(user_on_attach, true, client, bufnr)
  end
  return opts
end

return M
