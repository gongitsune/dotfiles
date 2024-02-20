local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local utils = require "core.utils"

autocmd({ "BufReadPost", "BufNewFile", "BufWritePost" }, {
  desc = "AstroNvim user events for file detection (AstroFile and AstroGitFile)",
  group = augroup("file_user_events", { clear = true }),
  callback = function(args)
    local current_file = vim.fn.resolve(vim.fn.expand "%")
    if not (current_file == "" or vim.api.nvim_get_option_value("buftype", { buf = args.buf }) == "nofile") then
      utils.event "File"
      if
          require("core.utils.git").file_worktree()
          or utils.cmd({ "git", "-C", vim.fn.fnamemodify(current_file, ":p:h"), "rev-parse" }, false)
      then
        utils.event "GitFile"
        vim.api.nvim_del_augroup_by_name "file_user_events"
      end
      vim.schedule(function() vim.api.nvim_exec_autocmds("CursorMoved", { modeline = false }) end)
    end
  end,
})
