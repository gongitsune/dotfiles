local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local namespace = vim.api.nvim_create_namespace

local utils = require("core.utils")

vim.on_key(function(char)
	if vim.fn.mode() == "n" then
		local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
		if vim.opt.hlsearch:get() ~= new_hlsearch then
			vim.opt.hlsearch = new_hlsearch
		end
	end
end, namespace("auto_hlsearch"))

autocmd("TextYankPost", {
	desc = "Highlight yanked text",
	group = augroup("highlightyank", { clear = true }),
	pattern = "*",
	callback = function()
		vim.highlight.on_yank()
	end,
})

autocmd({ "BufReadPost", "BufNewFile", "BufWritePost" }, {
	desc = "Nvim user events for file detection (MyFile and MyGitFile)",
	group = augroup("file_user_events", { clear = true }),
	callback = function(args)
		local current_file = vim.fn.resolve(vim.fn.expand("%"))
		if not (current_file == "" or vim.api.nvim_get_option_value("buftype", { buf = args.buf }) == "nofile") then
			utils.event("File")
			if
				require("core.utils.git").file_worktree()
				or utils.cmd({ "git", "-C", vim.fn.fnamemodify(current_file, ":p:h"), "rev-parse" }, false)
			then
				utils.event("GitFile")
				vim.api.nvim_del_augroup_by_name("file_user_events")
			end
			vim.schedule(function()
				vim.api.nvim_exec_autocmds("CursorMoved", { modeline = false })
			end)
		end
	end,
})

local bufferline_group = augroup("bufferline", { clear = true })
autocmd({ "BufAdd", "BufEnter", "TabNewEntered" }, {
	desc = "Update buffers when adding new buffers",
	group = bufferline_group,
	callback = function(args)
		local buf_utils = require("core.utils.buffer")
		if not vim.t.bufs then
			vim.t.bufs = {}
		end
		if not buf_utils.is_valid(args.buf) then
			return
		end
		if args.buf ~= buf_utils.current_buf then
			buf_utils.last_buf = buf_utils.is_valid(buf_utils.current_buf) and buf_utils.current_buf or nil
			buf_utils.current_buf = args.buf
		end
		local bufs = vim.t.bufs
		if not vim.tbl_contains(bufs, args.buf) then
			table.insert(bufs, args.buf)
			vim.t.bufs = bufs
		end
		vim.t.bufs = vim.tbl_filter(buf_utils.is_valid, vim.t.bufs)
		utils.event("BufsUpdated")
	end,
})
autocmd({ "BufDelete", "TermClose" }, {
	desc = "Update buffers when deleting buffers",
	group = bufferline_group,
	callback = function(args)
		local removed
		for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
			local bufs = vim.t[tab].bufs
			if bufs then
				for i, bufnr in ipairs(bufs) do
					if bufnr == args.buf then
						removed = true
						table.remove(bufs, i)
						vim.t[tab].bufs = bufs
						break
					end
				end
			end
		end
		vim.t.bufs = vim.tbl_filter(require("core.utils.buffer").is_valid, vim.t.bufs)
		if removed then
			utils.event("BufsUpdated")
		end
		vim.cmd.redrawtabline()
	end,
})

autocmd({ "BufWritePost" }, {
	callback = function()
		require("lint").try_lint()
		require("lint").try_lint("typos")
	end,
})
