if vim.loader and vim.fn.has "nvim-0.9.1" == 1 then vim.loader.enable() end

for _, source in ipairs {
  "core.bootstrap",
  "core.options",
  "core.lazy",
} do
  local status_ok, fault = pcall(require, source)
  if not status_ok then vim.api.nvim_err_writeln("Failed to load " .. source .. "\n\n" .. fault) end
end

if gconf.default_colorscheme then
  if not pcall(vim.cmd.colorscheme, gconf.default_colorscheme) then
    require("core.utils").notify(
      ("Error setting up colorscheme: `%s`"):format(gconf.default_colorscheme),
      vim.log.levels.ERROR
    )
  end
end
