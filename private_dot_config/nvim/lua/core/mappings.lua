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
maps.n["<C-q>"] = { "<cmd>qa!<cr>", desc = "Force quit" }
maps.n["|"] = { "<cmd>vsplit<cr>", desc = "Vertical Split" }
maps.n["\\"] = { "<cmd>split<cr>", desc = "Horizontal Split" }

-- navigate within insert mode
maps.i["<C-h>"] = { "<Left>", desc = "Move left" }
maps.i["<C-l>"] = { "<Right>", desc = "Move right" }
maps.i["<C-j>"] = { "<Down>", desc = "Move down" }
maps.i["<C-k>"] = { "<Up>", desc = "Move up" }

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

-- TODO: Add buffer pick
-- if is_available "heirline.nvim" then
--   maps.n["<leader>bb"] = {
--     function()
--       require("core.utils.status.heirline").buffer_picker(function(bufnr) vim.api.nvim_win_set_buf(0, bufnr) end)
--     end,
--     desc = "Select buffer from tabline",
--   }
--   maps.n["<leader>bd"] = {
--     function()
--       require("core.utils.status.heirline").buffer_picker(
--         function(bufnr) require("core.utils.buffer").close(bufnr) end
--       )
--     end,
--     desc = "Close buffer from tabline",
--   }
--   maps.n["<leader>b\\"] = {
--     function()
--       require("core.utils.status.heirline").buffer_picker(function(bufnr)
--         vim.cmd.split()
--         vim.api.nvim_win_set_buf(0, bufnr)
--       end)
--     end,
--     desc = "Horizontal split buffer from tabline",
--   }
--   maps.n["<leader>b|"] = {
--     function()
--       require("core.utils.status.heirline").buffer_picker(function(bufnr)
--         vim.cmd.vsplit()
--         vim.api.nvim_win_set_buf(0, bufnr)
--       end)
--     end,
--     desc = "Vertical split buffer from tabline",
--   }
-- end

-- Navigate tabs
maps.n["]t"] = { function() vim.cmd.tabnext() end, desc = "Next tab" }
maps.n["[t"] = { function() vim.cmd.tabprevious() end, desc = "Previous tab" }

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

-- Smart Splits
if is_available "smart-splits.nvim" then
  maps.n["<C-h>"] = { function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" }
  maps.n["<C-j>"] = { function() require("smart-splits").move_cursor_down() end, desc = "Move to below split" }
  maps.n["<C-k>"] = { function() require("smart-splits").move_cursor_up() end, desc = "Move to above split" }
  maps.n["<C-l>"] = { function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" }
  maps.n["<C-Up>"] = { function() require("smart-splits").resize_up() end, desc = "Resize split up" }
  maps.n["<C-Down>"] = { function() require("smart-splits").resize_down() end, desc = "Resize split down" }
  maps.n["<C-Left>"] = { function() require("smart-splits").resize_left() end, desc = "Resize split left" }
  maps.n["<C-Right>"] = { function() require("smart-splits").resize_right() end, desc = "Resize split right" }
else
  maps.n["<C-h>"] = { "<C-w>h", desc = "Move to left split" }
  maps.n["<C-j>"] = { "<C-w>j", desc = "Move to below split" }
  maps.n["<C-k>"] = { "<C-w>k", desc = "Move to above split" }
  maps.n["<C-l>"] = { "<C-w>l", desc = "Move to right split" }
  maps.n["<C-Up>"] = { "<cmd>resize -2<CR>", desc = "Resize split up" }
  maps.n["<C-Down>"] = { "<cmd>resize +2<CR>", desc = "Resize split down" }
  maps.n["<C-Left>"] = { "<cmd>vertical resize -2<CR>", desc = "Resize split left" }
  maps.n["<C-Right>"] = { "<cmd>vertical resize +2<CR>", desc = "Resize split right" }
end

-- SymbolsOutline
if is_available "aerial.nvim" then
  maps.n["<leader>l"] = sections.l
  maps.n["<leader>lS"] = { function() require("aerial").toggle() end, desc = "Symbols outline" }
end

-- Telescope
if is_available "telescope.nvim" then
  maps.n["<leader>f"] = sections.f
  maps.n["<leader>g"] = sections.g
  maps.n["<leader>gb"] =
  { function() require("telescope.builtin").git_branches { use_file_path = true } end, desc = "Git branches" }
  maps.n["<leader>gc"] = {
    function() require("telescope.builtin").git_commits { use_file_path = true } end,
    desc = "Git commits (repository)",
  }
  maps.n["<leader>gC"] = {
    function() require("telescope.builtin").git_bcommits { use_file_path = true } end,
    desc = "Git commits (current file)",
  }
  maps.n["<leader>gt"] =
  { function() require("telescope.builtin").git_status { use_file_path = true } end, desc = "Git status" }
  maps.n["<leader>f<CR>"] = { function() require("telescope.builtin").resume() end, desc = "Resume previous search" }
  maps.n["<leader>f'"] = { function() require("telescope.builtin").marks() end, desc = "Find marks" }
  maps.n["<leader>f/"] =
  { function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "Find words in current buffer" }
  maps.n["<leader>fb"] = { function() require("telescope.builtin").buffers() end, desc = "Find buffers" }
  maps.n["<leader>fc"] = { function() require("telescope.builtin").grep_string() end, desc = "Find word under cursor" }
  maps.n["<leader>fC"] = { function() require("telescope.builtin").commands() end, desc = "Find commands" }
  maps.n["<leader>ff"] = { function() require("telescope.builtin").find_files() end, desc = "Find files" }
  maps.n["<leader>fF"] = {
    function() require("telescope.builtin").find_files { hidden = true, no_ignore = true } end,
    desc = "Find all files",
  }
  maps.n["<leader>fh"] = { function() require("telescope.builtin").help_tags() end, desc = "Find help" }
  maps.n["<leader>fk"] = { function() require("telescope.builtin").keymaps() end, desc = "Find keymaps" }
  maps.n["<leader>fm"] = { function() require("telescope.builtin").man_pages() end, desc = "Find man" }
  if is_available "nvim-notify" then
    maps.n["<leader>fn"] =
    { function() require("telescope").extensions.notify.notify() end, desc = "Find notifications" }
    maps.n["<leader>uD"] =
    { function() require("notify").dismiss { pending = true, silent = true } end, desc = "Dismiss notifications" }
  end
  maps.n["<leader>fo"] = { function() require("telescope.builtin").oldfiles() end, desc = "Find history" }
  maps.n["<leader>fr"] = { function() require("telescope.builtin").registers() end, desc = "Find registers" }
  maps.n["<leader>ft"] =
  { function() require("telescope.builtin").colorscheme { enable_preview = true } end, desc = "Find themes" }
  maps.n["<leader>fw"] = { function() require("telescope.builtin").live_grep() end, desc = "Find words" }
  maps.n["<leader>fW"] = {
    function()
      require("telescope.builtin").live_grep {
        additional_args = function(args) return vim.list_extend(args, { "--hidden", "--no-ignore" }) end,
      }
    end,
    desc = "Find words in all files",
  }
  maps.n["<leader>l"] = sections.l
  maps.n["<leader>ls"] = {
    function()
      local aerial_avail, _ = pcall(require, "aerial")
      if aerial_avail then
        require("telescope").extensions.aerial.aerial()
      else
        require("telescope.builtin").lsp_document_symbols()
      end
    end,
    desc = "Search symbols",
  }
end

-- Terminal
if is_available "toggleterm.nvim" then
  maps.n["<leader>t"] = sections.t
  if vim.fn.executable "lazygit" == 1 then
    maps.n["<leader>g"] = sections.g
    maps.n["<leader>gg"] = {
      function()
        local worktree = require("core.utils.git").file_worktree()
        local flags = worktree and (" --work-tree=%s --git-dir=%s"):format(worktree.toplevel, worktree.gitdir) or ""
        utils.toggle_term_cmd("lazygit " .. flags)
      end,
      desc = "ToggleTerm lazygit",
    }
    maps.n["<leader>tl"] = maps.n["<leader>gg"]
  end
  if vim.fn.executable "node" == 1 then
    maps.n["<leader>tn"] = { function() utils.toggle_term_cmd "node" end, desc = "ToggleTerm node" }
  end
  local gdu = vim.fn.has "mac" == 1 and "gdu-go" or "gdu"
  if vim.fn.executable(gdu) == 1 then
    maps.n["<leader>tu"] = { function() utils.toggle_term_cmd(gdu) end, desc = "ToggleTerm gdu" }
  end
  if vim.fn.executable "btm" == 1 then
    maps.n["<leader>tt"] = { function() utils.toggle_term_cmd "btm" end, desc = "ToggleTerm btm" }
  end
  local python = vim.fn.executable "python" == 1 and "python" or vim.fn.executable "python3" == 1 and "python3"
  if python then maps.n["<leader>tp"] = { function() utils.toggle_term_cmd(python) end, desc = "ToggleTerm python" } end
  maps.n["<leader>tf"] = { "<cmd>ToggleTerm direction=float<cr>", desc = "ToggleTerm float" }
  maps.n["<leader>th"] = { "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "ToggleTerm horizontal split" }
  maps.n["<leader>tv"] = { "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "ToggleTerm vertical split" }
  maps.n["<F7>"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" }
  maps.t["<F7>"] = maps.n["<F7>"]
  maps.n["<C-'>"] = maps.n["<F7>"] -- requires terminal that supports binding <C-'>
  maps.t["<C-'>"] = maps.n["<F7>"] -- requires terminal that supports binding <C-'>
end

-- Stay in indent mode
maps.v["<S-Tab>"] = { "<gv", desc = "Unindent line" }
maps.v["<Tab>"] = { ">gv", desc = "Indent line" }

-- Improved Terminal Navigation
maps.t["<C-h>"] = { "<cmd>wincmd h<cr>", desc = "Terminal left window navigation" }
maps.t["<C-j>"] = { "<cmd>wincmd j<cr>", desc = "Terminal down window navigation" }
maps.t["<C-k>"] = { "<cmd>wincmd k<cr>", desc = "Terminal up window navigation" }
maps.t["<C-l>"] = { "<cmd>wincmd l<cr>", desc = "Terminal right window navigation" }

maps.n["<leader>u"] = sections.u
-- Custom menu for modification of the user experience
-- if is_available "nvim-autopairs" then maps.n["<leader>ua"] = { ui.toggle_autopairs, desc = "Toggle autopairs" } end
-- maps.n["<leader>ub"] = { ui.toggle_background, desc = "Toggle background" }
-- if is_available "nvim-cmp" then maps.n["<leader>uc"] = { ui.toggle_cmp, desc = "Toggle autocompletion" } end
-- if is_available "nvim-colorizer.lua" then
--   maps.n["<leader>uC"] = { "<cmd>ColorizerToggle<cr>", desc = "Toggle color highlight" }
-- end
-- maps.n["<leader>ud"] = { ui.toggle_diagnostics, desc = "Toggle diagnostics" }
-- maps.n["<leader>ug"] = { ui.toggle_signcolumn, desc = "Toggle signcolumn" }
-- maps.n["<leader>ui"] = { ui.set_indent, desc = "Change indent setting" }
-- maps.n["<leader>ul"] = { ui.toggle_statusline, desc = "Toggle statusline" }
-- maps.n["<leader>uL"] = { ui.toggle_codelens, desc = "Toggle CodeLens" }
-- maps.n["<leader>un"] = { ui.change_number, desc = "Change line numbering" }
-- maps.n["<leader>uN"] = { ui.toggle_ui_notifications, desc = "Toggle Notifications" }
-- maps.n["<leader>up"] = { ui.toggle_paste, desc = "Toggle paste mode" }
-- maps.n["<leader>us"] = { ui.toggle_spell, desc = "Toggle spellcheck" }
-- maps.n["<leader>uS"] = { ui.toggle_conceal, desc = "Toggle conceal" }
-- maps.n["<leader>ut"] = { ui.toggle_tabline, desc = "Toggle tabline" }
-- maps.n["<leader>uu"] = { ui.toggle_url_match, desc = "Toggle URL highlight" }
-- maps.n["<leader>uw"] = { ui.toggle_wrap, desc = "Toggle wrap" }
-- maps.n["<leader>uy"] = { ui.toggle_syntax, desc = "Toggle syntax highlighting (buffer)" }
-- maps.n["<leader>uh"] = { ui.toggle_foldcolumn, desc = "Toggle foldcolumn" }

utils.set_mappings(maps)
