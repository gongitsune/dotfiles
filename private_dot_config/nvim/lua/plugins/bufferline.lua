return {
	{
		"akinsho/bufferline.nvim",
		event = "BufEnter",
		branch = "main",
		dependencies = "nvim-tree/nvim-web-devicons",
		opts = function()
			return {
				options = {
					separator_style = "slant",
					offsets = {
						{
							filetype = "NvimTree",
							text = "File Explorer",
							separator = true,
							text_align = "center",
						},
					},
					close_command = require("core.utils.buffer").close,
				},
				highlights = require("nord.plugins.bufferline").akinsho(),
			}
		end,
		config = function(_, opts)
			require("bufferline").setup(opts)
		end,
	},
}
