local function get_clients()
	local prefix = " "
	local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
	local nvim_clients = vim.lsp.get_clients()
	local clients = {}
	if next(nvim_clients) == nil then
		return prefix .. "No Active"
	end
	for _, client in ipairs(nvim_clients) do
		---@diagnostic disable-next-line: undefined-field
		local filetypes = client.config.filetypes
		if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
			table.insert(clients, client.name)
		end
	end
	return prefix .. table.concat(clients, ", ")
end

return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "BufEnter",
		opts = {
			options = {
				theme = "nord",
				component_separators = "|",
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = {
					{ "mode", separator = { left = "" }, right_padding = 2 },
				},
				lualine_b = { "filename", "branch", "diff" },
				lualine_c = { "fileformat", "diagnostics" },
				lualine_x = { get_clients },
				lualine_y = { "copilot", "filetype", "progress" },
				lualine_z = {
					{ "location", separator = { right = "" }, left_padding = 2 },
				},
			},
			inactive_sections = {
				lualine_a = { "filename" },
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = { "location" },
			},
			tabline = {},
			extensions = {},
		},
		config = function(_, opts)
			require("lualine").setup(opts)
		end,
	},
	{ "AndreM222/copilot-lualine" },
}
