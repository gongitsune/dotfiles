return {
  {
    'mrcjkb/haskell-tools.nvim',
    ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
    init = function()
      vim.g.haskell_tools = {
        -- @type HaskellLspClientOpts
        hls = {
          ---@param client number The LSP client ID.
          ---@param bufnr number The buffer number
          ---@param ht HaskellTools = require('haskell-tools')
          on_attach = function(client, bufnr, ht)
            require "core.utils.lsp".on_attach(client, bufnr)

            local ht_mapping = require "core.utils".empty_map_table()
            ht_mapping.n["<leader>hs"] = {
              ht.hoogle.hoogle_signature,
              desc = "Hoogle search for the type signature"
            }
            ht_mapping.n["<leader>he"] = {
              ht.lsp.buf_eval_all,
              desc = "Evaluate all code snippets"
            }
            ht_mapping.n["<leader>hr"] = {
              ht.repl.toggle,
              desc = "Toggle a GHCi repl for the current package"
            }
            ht_mapping.n["<leader>hR"] = {
              function()
                ht.repl.toggle(vim.api.nvim_buf_get_name(0))
              end,
              desc = "Toggle a GHCi repl for the current buffer"
            }
            ht_mapping.n["<leader>hq"] = {
              ht.repl.quit,
              desc = "Quit a GHCi repl"
            }

            require "core.utils".set_mappings(ht_mapping, { buffer = bufnr })
          end
        }
      }
    end
  }
}
