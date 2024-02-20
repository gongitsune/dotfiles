local M = {}

local function bool2str(bool) return bool and "on" or "off" end
local function ui_notify(silent, ...) return not silent and require("astronvim.utils").notify(...) end

--- Toggle auto format
---@param silent? boolean if true then don't sent a notification
function M.toggle_autoformat(silent)
  vim.g.autoformat_enabled = not vim.g.autoformat_enabled
  ui_notify(silent, string.format("Global autoformatting %s", bool2str(vim.g.autoformat_enabled)))
end

--- Toggle buffer local auto format
---@param bufnr? number the buffer to toggle syntax on
---@param silent? boolean if true then don't sent a notification
function M.toggle_buffer_autoformat(bufnr, silent)
  bufnr = bufnr or 0
  local old_val = vim.b[bufnr].autoformat_enabled
  if old_val == nil then old_val = vim.g.autoformat_enabled end
  vim.b[bufnr].autoformat_enabled = not old_val
  ui_notify(silent, string.format("Buffer autoformatting %s", bool2str(vim.b[bufnr].autoformat_enabled)))
end

--- Toggle buffer semantic token highlighting for all language servers that support it
---@param bufnr? number the buffer to toggle the clients on
---@param silent? boolean if true then don't sent a notification
function M.toggle_buffer_semantic_tokens(bufnr, silent)
  bufnr = bufnr or 0
  vim.b[bufnr].semantic_tokens_enabled = not vim.b[bufnr].semantic_tokens_enabled
  local toggled = false
  for _, client in ipairs(vim.lsp.get_active_clients { bufnr = bufnr }) do
    if client.server_capabilities.semanticTokensProvider then
      vim.lsp.semantic_tokens[vim.b[bufnr].semantic_tokens_enabled and "start" or "stop"](bufnr, client.id)
      toggled = true
    end
  end
  ui_notify(
    not toggled or silent,
    string.format("Buffer lsp semantic highlighting %s", bool2str(vim.b[bufnr].semantic_tokens_enabled))
  )
end

return M
