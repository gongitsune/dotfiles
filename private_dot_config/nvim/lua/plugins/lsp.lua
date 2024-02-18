return {
  { "b0o/SchemaStore.nvim" },
  {
    "folke/neodev.nvim",
    lazy = true,
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/neoconf.nvim",
        opts = {
          -- import existing settings from other plugins
          import = {
            vscode = true, -- local .vscode/settings.json
            coc = false,   -- global/local coc-settings.json
            nlsp = false,  -- global/local nlsp-settings.nvim json settings
          },
        },
      },
      {
        "williamboman/mason-lspconfig.nvim",
        cmd = { "LspInstall", "LspUninstall" },
        opts = function(_, opts)
          if not opts.handlers then opts.handlers = {} end
          opts.handlers[1] = function(server) require("core.utils.lsp").setup(server) end
          opts.ensure_installed = require("core.utils.custom").user_opts("mason",
                { ensure_installed = opts.ensure_installed })
              .ensure_installed
        end,
        config = function(_, opts)
          require("mason-lspconfig").setup(opts)
          require("core.utils").event "MasonLspSetup"
        end,
      },
    },
    cmd = function(_, cmds) -- HACK: lazy load lspconfig on `:Neoconf` if neoconf is available
      if require("core.utils").is_available "neoconf.nvim" then table.insert(cmds, "Neoconf") end
    end,
    event = { "User File" },
    config = function(_, _)
      local lsp = require "core.utils.lsp"
      local utils = require "core.utils"
      local custom = require "core.utils.custom"
      local get_icon = utils.get_icon
      local signs = {
        { name = "DiagnosticSignError",    text = get_icon "DiagnosticError",        texthl = "DiagnosticSignError" },
        { name = "DiagnosticSignWarn",     text = get_icon "DiagnosticWarn",         texthl = "DiagnosticSignWarn" },
        { name = "DiagnosticSignHint",     text = get_icon "DiagnosticHint",         texthl = "DiagnosticSignHint" },
        { name = "DiagnosticSignInfo",     text = get_icon "DiagnosticInfo",         texthl = "DiagnosticSignInfo" },
        { name = "DapStopped",             text = get_icon "DapStopped",             texthl = "DiagnosticWarn" },
        { name = "DapBreakpoint",          text = get_icon "DapBreakpoint",          texthl = "DiagnosticInfo" },
        { name = "DapBreakpointRejected",  text = get_icon "DapBreakpointRejected",  texthl = "DiagnosticError" },
        { name = "DapBreakpointCondition", text = get_icon "DapBreakpointCondition", texthl = "DiagnosticInfo" },
        { name = "DapLogPoint",            text = get_icon "DapLogPoint",            texthl = "DiagnosticInfo" },
      }

      for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign.name, sign)
      end
      lsp.setup_diagnostics(signs)

      local orig_handler = vim.lsp.handlers["$/progress"]
      vim.lsp.handlers["$/progress"] = function(_, msg, info)
        local progress, id = custom.lsp.progress, ("%s.%s"):format(info.client_id, msg.token)
        progress[id] = progress[id] and utils.extend_tbl(progress[id], msg.value) or msg.value
        if progress[id].kind == "end" then
          vim.defer_fn(function()
            progress[id] = nil
            utils.event "LspProgress"
          end, 100)
        end
        utils.event "LspProgress"
        orig_handler(_, msg, info)
      end

      if vim.g.lsp_handlers_enabled then
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover,
          { border = "rounded", silent = true })
        vim.lsp.handlers["textDocument/signatureHelp"] =
            vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded", silent = true })
      end
      local setup_servers = function()
        vim.tbl_map(require("core.utils.lsp").setup, custom.user_opts "lsp.servers")
        vim.api.nvim_exec_autocmds("FileType", { modeline = false })
        require("core.utils").event "LspSetup"
      end
      if require("core.utils").is_available "mason-lspconfig.nvim" then
        vim.api.nvim_create_autocmd("User", {
          desc = "set up LSP servers after mason-lspconfig",
          pattern = "MasonLspSetup",
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
    event = "User File",
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
}
