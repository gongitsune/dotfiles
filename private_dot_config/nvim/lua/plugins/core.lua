return {
	{
		"nvim-lua/plenary.nvim",
		lazy = true,
	},
	{
		"max397574/better-escape.nvim",
		event = "InsertCharPre",
		opts = { timeout = 300 },
	},
	{
		"NMAC427/guess-indent.nvim",
		event = "User MyFile",
		config = function(_, opts)
			require("guess-indent").setup(opts)
			vim.cmd.lua({ args = { "require('guess-indent').set_from_buffer('auto_cmd')" }, mods = { silent = true } })
		end,
	},
	{
		"mrjones2014/smart-splits.nvim",
		lazy = true,
		opts = { ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" }, ignored_buftypes = { "nofile" } },
	},
	{
		"windwp/nvim-autopairs",
		event = "User MyFile",
		opts = {
			check_ts = true,
			ts_config = { java = false },
			fast_wrap = {
				map = "<M-e>",
				chars = { "{", "[", "(", '"', "'" },
				pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
				offset = 0,
				end_key = "$",
				keys = "qwertyuiopzxcvbnmasdfghjkl",
				check_comma = true,
				highlight = "PmenuSel",
				highlight_grey = "LineNr",
			},
		},
		config = function(_, opts)
			local npairs = require("nvim-autopairs")
			npairs.setup(opts)

			if not vim.g.autopairs_enabled then
				npairs.disable()
			end
			local cmp_status_ok, cmp = pcall(require, "cmp")
			if cmp_status_ok then
				cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done({ tex = false }))
			end
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			icons = { group = vim.g.icons_enabled and "" or "+", separator = "" },
			disable = { filetypes = { "TelescopePrompt" } },
		},
		config = function(_, opts)
			require("which-key").setup(opts)
			require("core.utils").which_key_register()
		end,
	},
	{
		"numToStr/Comment.nvim",
		keys = {
			{ "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
			{ "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
		},
		opts = function()
			local commentstring_avail, commentstring =
				pcall(require, "ts_context_commentstring.integrations.comment_nvim")
			return commentstring_avail and commentstring and { pre_hook = commentstring.create_pre_hook() } or {}
		end,
	},
	{
		"akinsho/toggleterm.nvim",
		cmd = { "ToggleTerm", "TermExec" },
		opts = {
			highlights = {
				Normal = { link = "Normal" },
				NormalNC = { link = "NormalNC" },
				NormalFloat = { link = "NormalFloat" },
				FloatBorder = { link = "FloatBorder" },
				StatusLine = { link = "StatusLine" },
				StatusLineNC = { link = "StatusLineNC" },
				WinBar = { link = "WinBar" },
				WinBarNC = { link = "WinBarNC" },
			},
			size = 10,
			on_create = function()
				vim.opt.foldcolumn = "0"
				vim.opt.signcolumn = "no"
			end,
			open_mapping = [[<F7>]],
			shading_factor = 2,
			direction = "float",
			float_opts = { border = "rounded" },
		},
	},
}
