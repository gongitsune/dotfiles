return {
	{ "b0o/SchemaStore.nvim", lazy = true },
	{
		"folke/neodev.nvim",
		lazy = true,
		opts = {
			override = function(root_dir, library)
				if root_dir:match(vim.fn.stdpath("config")) then
					library.plugins = true
				end
				vim.b.neodev_enabled = library.enabled
			end,
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"folke/neoconf.nvim",
				opts = {},
				config = function(_, opts)
					require("neoconf").setup(opts)
				end,
			},
			{
				"williamboman/mason-lspconfig.nvim",
				cmd = { "LspInstall", "LspUninstall" },
				config = function(_, opts)
					require("mason-lspconfig").setup(opts)
					require("core.utils.lsp").setup_handlers()
					require("core.utils").event("MasonLspSetup")
				end,
			},
		},
		cmd = function(_, cmds) -- HACK: lazy load lspconfig on `:Neoconf` if neoconf is available
			if require("core.utils").is_available("neoconf.nvim") then
				table.insert(cmds, "Neoconf")
			end
		end,
		event = "User MyFile",
		config = function(_, _)
			local utils = require("core.utils")
			local lsp = require("core.utils.lsp")
			local get_icon = utils.get_icon
			local signs = {
				{
					name = "DiagnosticSignError",
					text = get_icon("DiagnosticError"),
					texthl = "DiagnosticSignError",
				},
				{
					name = "DiagnosticSignWarn",
					text = get_icon("DiagnosticWarn"),
					texthl = "DiagnosticSignWarn",
				},
				{
					name = "DiagnosticSignHint",
					text = get_icon("DiagnosticHint"),
					texthl = "DiagnosticSignHint",
				},
				{
					name = "DiagnosticSignInfo",
					text = get_icon("DiagnosticInfo"),
					texthl = "DiagnosticSignInfo",
				},
				{
					name = "DapStopped",
					text = get_icon("DapStopped"),
					texthl = "DiagnosticWarn",
				},
				{
					name = "DapBreakpoint",
					text = get_icon("DapBreakpoint"),
					texthl = "DiagnosticInfo",
				},
				{
					name = "DapBreakpointRejected",
					text = get_icon("DapBreakpointRejected"),
					texthl = "DiagnosticError",
				},
				{
					name = "DapBreakpointCondition",
					text = get_icon("DapBreakpointCondition"),
					texthl = "DiagnosticInfo",
				},
				{
					name = "DapLogPoint",
					text = get_icon("DapLogPoint"),
					texthl = "DiagnosticInfo",
				},
			}

			for _, sign in ipairs(signs) do
				vim.fn.sign_define(sign.name, sign)
			end
			lsp.setup_diagnostics(signs)

			local setup_servers = function()
				vim.api.nvim_exec_autocmds("FileType", { modeline = false })
				require("core.utils").event("LspSetup")
			end
			if require("core.utils").is_available("mason-lspconfig.nvim") then
				vim.api.nvim_create_autocmd("User", {
					desc = "set up LSP servers after mason-lspconfig",
					pattern = "MyMasonLspSetup",
					once = true,
					callback = setup_servers,
				})
			else
				setup_servers()
			end
		end,
	},
	{
		"stevearc/aerial.nvim",
		event = "User MyFile",
		opts = {
			attach_mode = "global",
			backends = { "lsp", "treesitter", "markdown", "man" },
			disable_max_lines = vim.g.max_file.lines,
			disable_max_size = vim.g.max_file.size,
			layout = { min_width = 28 },
			show_guides = true,
			filter_kind = false,
			guides = {
				mid_item = "├ ",
				last_item = "└ ",
				nested_top = "│ ",
				whitespace = "  ",
			},
			keymaps = {
				["[y"] = "actions.prev",
				["]y"] = "actions.next",
				["[Y"] = "actions.prev_up",
				["]Y"] = "actions.next_up",
				["{"] = false,
				["}"] = false,
				["[["] = false,
				["]]"] = false,
			},
		},
	},
	{
		"mfussenegger/nvim-lint",
		event = "User MyFile",
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				haskell = { "hlint", "cspell" },
				rust = { "cspell" },
				glsl = { "glslc", "cspell" },
				typescript = { "biomejs" },
				javascript = { "biomejs" },
				typescriptreact = { "biomejs" },
				javascriptreact = { "biomejs" },
				markdown = { "markdownlint" },
			}
		end,
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				haskell = { "fourmolu" },
				html = { "biome" },
				typescript = { "biome" },
				javascrip = { "biome" },
				typescriptreact = { "biome" },
				javascriptreact = { "biome" },
				rust = { "rustfmt" },
				glsl = { "clang_format" },
				json = { "biome" },
				python = { "ruff" },
				markdown = { "markdownlint" },
				c = { "clang_format" },
			},
		},
		config = function(_, opts)
			require("conform").setup(opts)
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					-- LSP servers
					"lua-language-server",
					"rust_analyzer",
					"jsonls",
					"pyright",
					"clangd",
					"taplo",
					"tailwindcss-language-server",

					-- Formatters & Linters
					"stylua",
					"markdownlint",
					"ruff",
					"fourmolu",
					"biome",
					"cspell",
					"clang-format",
				},
			})
		end,
	},
}
