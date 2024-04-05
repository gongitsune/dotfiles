local M = {}

local utils = require("core.utils")

--- Placeholders for keeping track of most recent and previous buffer
M.current_buf, M.last_buf = nil, nil

-- TODO: Add user configuration table for this once resession is default
--- Configuration table for controlling session options
M.sessions = {
	autosave = {
		last = true, -- auto save last session
		cwd = true, -- auto save session for each working directory
	},
	ignore = {
		dirs = {}, -- working directories to ignore sessions in
		filetypes = { "gitcommit", "gitrebase" }, -- filetypes to ignore sessions
		buftypes = {}, -- buffer types to ignore sessions
	},
}

--- Check if a buffer is valid
---@param bufnr number? The buffer to check, default to current buffer
---@return boolean # Whether the buffer is valid or not
function M.is_valid(bufnr)
	if not bufnr then
		bufnr = 0
	end
	return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted
end

--- Move the current buffer tab n places in the bufferline
---@param n number The number of tabs to move the current buffer over by (positive = right, negative = left)
function M.move(n)
	if n == 0 then
		return
	end -- if n = 0 then no shifts are needed
	local bufs = vim.t.bufs -- make temp variable
	for i, bufnr in ipairs(bufs) do -- loop to find current buffer
		if bufnr == vim.api.nvim_get_current_buf() then -- found index of current buffer
			for _ = 0, (n % #bufs) - 1 do -- calculate number of right shifts
				local new_i = i + 1 -- get next i
				if i == #bufs then -- if at end, cycle to beginning
					new_i = 1 -- next i is actually 1 if at the end
					local val = bufs[i] -- save value
					table.remove(bufs, i) -- remove from end
					table.insert(bufs, new_i, val) -- insert at beginning
				else -- if not at the end,then just do an in place swap
					bufs[i], bufs[new_i] = bufs[new_i], bufs[i]
				end
				i = new_i -- iterate i to next value
			end
			break
		end
	end
	vim.t.bufs = bufs -- set buffers
	utils.event("BufsUpdated")
	vim.cmd.redrawtabline() -- redraw tabline
end

--- Close a given buffer
---@param bufnr? number The buffer to close or the current buffer if not provided
---@param force? boolean Whether or not to foce close the buffers or confirm changes (default: false)
function M.close(bufnr, force)
	if not bufnr or bufnr == 0 then
		bufnr = vim.api.nvim_get_current_buf()
	end

	if utils.is_available("mini.bufremove") and M.is_valid(bufnr) then
		if not force and vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
			local bufname = vim.fn.expand("%")
			local empty = bufname == ""
			if empty then
				bufname = "Untitled"
			end
			local confirm =
				vim.fn.confirm(('Save changes to "%s"?'):format(bufname), "&Yes\n&No\n&Cancel", 1, "Question")
			if confirm == 1 then
				if empty then
					return
				end
				vim.cmd.write()
			elseif confirm == 2 then
				force = true
			else
				return
			end
		end
		require("mini.bufremove").delete(bufnr, force)
	else
		local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
		vim.cmd(("silent! %s %d"):format((force or buftype == "terminal") and "bdelete!" or "confirm bdelete", bufnr))
	end
end

--- Close all buffers
---@param keep_current? boolean Whether or not to keep the current buffer (default: false)
---@param force? boolean Whether or not to foce close the buffers or confirm changes (default: false)
function M.close_all(keep_current, force)
	if keep_current == nil then
		keep_current = false
	end
	local current = vim.api.nvim_get_current_buf()
	for _, bufnr in ipairs(vim.t.bufs) do
		if not keep_current or bufnr ~= current then
			M.close(bufnr, force)
		end
	end
end

--- Check if a buffer can be restored
---@param bufnr number The buffer to check
---@return boolean # Whether the buffer is restorable or not
function M.is_restorable(bufnr)
	if not M.is_valid(bufnr) or vim.api.nvim_get_option_value("bufhidden", { buf = bufnr }) ~= "" then
		return false
	end

	local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
	if buftype == "" then
		-- Normal buffer, check if it listed.
		if not vim.api.nvim_get_option_value("buflisted", { buf = bufnr }) then
			return false
		end
		-- Check if it has a filename.
		if vim.api.nvim_buf_get_name(bufnr) == "" then
			return false
		end
	end

	if
		vim.tbl_contains(M.sessions.ignore.filetypes, vim.api.nvim_get_option_value("filetype", { buf = bufnr }))
		or vim.tbl_contains(M.sessions.ignore.buftypes, vim.api.nvim_get_option_value("buftype", { buf = bufnr }))
	then
		return false
	end
	return true
end

return M
