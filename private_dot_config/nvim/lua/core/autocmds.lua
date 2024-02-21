local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local namespace = vim.api.nvim_create_namespace

local utils = require "core.utils"

vim.on_key(function(char)
  if vim.fn.mode() == "n" then
    local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
    if vim.opt.hlsearch:get() ~= new_hlsearch then vim.opt.hlsearch = new_hlsearch end
  end
end, namespace "auto_hlsearch")

autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  group = augroup("highlightyank", { clear = true }),
  pattern = "*",
  callback = function() vim.highlight.on_yank() end,
})

autocmd({ "BufReadPost", "BufNewFile", "BufWritePost" }, {
  desc = "Nvim user events for file detection (MyFile and MyGitFile)",
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
