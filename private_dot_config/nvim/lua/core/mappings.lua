local utils = require "core.utils"
local get_icon = utils.get_icon
local is_available = utils.is_available

local maps = utils.empty_map_table()

local sections = {
  f = { desc = get_icon("Search", 1, true) .. "Find" },
  p = { desc = get_icon("Package", 1, true) .. "Packages" },
  l = { desc = get_icon("ActiveLSP", 1, true) .. "LSP" },
  u = { desc = get_icon("Window", 1, true) .. "UI/UX" },
  b = { desc = get_icon("Tab", 1, true) .. "Buffers" },
  bs = { desc = get_icon("Sort", 1, true) .. "Sort Buffers" },
  d = { desc = get_icon("Debugger", 1, true) .. "Debugger" },
  g = { desc = get_icon("Git", 1, true) .. "Git" },
  S = { desc = get_icon("Session", 1, true) .. "Session" },
  t = { desc = get_icon("Terminal", 1, true) .. "Terminal" },
}

-- Normal --
-- Standard Operations
maps.n["j"] = { "v:count == 0 ? 'gj' : 'j'", expr = true, desc = "Move cursor down" }
maps.n["k"] = { "v:count == 0 ? 'gk' : 'k'", expr = true, desc = "Move cursor up" }
maps.n["<Leader>w"] = { "<cmd>w<cr>", desc = "Save" }
maps.n["<Leader>q"] = { "<cmd>confirm q<cr>", desc = "Quit" }
maps.n["<Leader>Q"] = { "<cmd>confirm qall<cr>", desc = "Quit all" }
maps.n["<Leader>n"] = { "<cmd>enew<cr>", desc = "New File" }
maps.n["<C-s>"] = { "<cmd>w!<cr>", desc = "Force write" }
maps.n["<C-q>"] = { "<cmd>qa!<cr>", desc = "Force quit" }
maps.n["|"] = { "<cmd>vsplit<cr>", desc = "Vertical Split" }
maps.n["\\"] = { "<cmd>split<cr>", desc = "Horizontal Split" }

-- Plugin Manager
maps.n["<Leader>p"] = sections.p
maps.n["<Leader>pi"] = { function() require("lazy").install() end, desc = "Plugins Install" }
maps.n["<Leader>ps"] = { function() require("lazy").home() end, desc = "Plugins Status" }
maps.n["<Leader>pS"] = { function() require("lazy").sync() end, desc = "Plugins Sync" }
maps.n["<Leader>pu"] = { function() require("lazy").check() end, desc = "Plugins Check Updates" }
maps.n["<Leader>pU"] = { function() require("lazy").update() end, desc = "Plugins Update" }

-- Manage Buffers
maps.n["<leader>c"] = { function() require("core.utils.buffer").close() end, desc = "Close buffer" }
maps.n["<leader>C"] = { function() require("core.utils.buffer").close(0, true) end, desc = "Force close buffer" }
maps.n["]b"] = {
  "<cmd>BufferLineCycleNext<cr>",
  desc = "Next buffer"
}
maps.n["[b"] = {
  "<cmd>BufferLineCyclePrev<cr>",
  desc = "Previous buffer",
}
maps.n[">b"] = {
  function() require("core.utils.buffer").move(vim.v.count > 0 and vim.v.count or 1) end,
  desc = "Move buffer tab right",
}
maps.n["<b"] = {
  function() require("core.utils.buffer").move(-(vim.v.count > 0 and vim.v.count or 1)) end,
  desc = "Move buffer tab left",
}

maps.n["<leader>b"] = sections.b
maps.n["<leader>bc"] = { "<cmd>BufferLineCloseOthers<cr>", desc = "Close all buffers except current" }
maps.n["<leader>bC"] = { function() require("core.utils.buffer").close_all() end, desc = "Close all buffers" }
maps.n["<leader>bl"] = { "<cmd>BufferLineCloseLeft<cr>", desc = "Close all buffers to the left" }
maps.n["<leader>br"] = { "<cmd>BufferLineCloseRight<cr>", desc = "Close all buffers to the right" }
-- TODO: Add buffer sort
-- maps.n["<leader>bs"] = sections.bs
-- maps.n["<leader>bse"] = { function() require("core.utils.buffer").sort "extension" end, desc = "By extension" }
-- maps.n["<leader>bsr"] =
-- { function() require("core.utils.buffer").sort "unique_path" end, desc = "By relative path" }
-- maps.n["<leader>bsp"] = { function() require("core.utils.buffer").sort "full_path" end, desc = "By full path" }
-- maps.n["<leader>bsi"] = { function() require("core.utils.buffer").sort "bufnr" end, desc = "By buffer number" }
-- maps.n["<leader>bsm"] = { function() require("core.utils.buffer").sort "modified" end, desc = "By modification" }

if is_available "heirline.nvim" then
  maps.n["<leader>bb"] = {
    function()
      require("core.utils.status.heirline").buffer_picker(function(bufnr) vim.api.nvim_win_set_buf(0, bufnr) end)
    end,
    desc = "Select buffer from tabline",
  }
  maps.n["<leader>bd"] = {
    function()
      require("core.utils.status.heirline").buffer_picker(
        function(bufnr) require("core.utils.buffer").close(bufnr) end
      )
    end,
    desc = "Close buffer from tabline",
  }
  maps.n["<leader>b\\"] = {
    function()
      require("core.utils.status.heirline").buffer_picker(function(bufnr)
        vim.cmd.split()
        vim.api.nvim_win_set_buf(0, bufnr)
      end)
    end,
    desc = "Horizontal split buffer from tabline",
  }
  maps.n["<leader>b|"] = {
    function()
      require("core.utils.status.heirline").buffer_picker(function(bufnr)
        vim.cmd.vsplit()
        vim.api.nvim_win_set_buf(0, bufnr)
      end)
    end,
    desc = "Vertical split buffer from tabline",
  }
end

-- Comment
if is_available "Comment.nvim" then
  maps.n["<Leader>/"] = {
    function() require("Comment.api").toggle.linewise.count(vim.v.count > 0 and vim.v.count or 1) end,
    desc = "Toggle comment line",
  }
  maps.v["<Leader>/"] = {
    "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
    desc = "Toggle comment for selection",
  }
end

-- Nvim-Tree
if is_available "nvim-tree.lua" then
  maps.n["<leader>e"] = { "<cmd>NvimTreeToggle<cr>", desc = "Toggle Explorer" }
end

-- Package Manager
if is_available "mason.nvim" then
  maps.n["<leader>pm"] = { "<cmd>Mason<cr>", desc = "Mason Installer" }
  maps.n["<leader>pM"] = { "<cmd>MasonUpdateAll<cr>", desc = "Mason Update" }
end

utils.set_mappings(maps)
