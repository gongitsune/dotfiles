return {
  "nvim-tree/nvim-tree.lua",
  cmd = { "NvimTreeToggle", "NvimTreeFocus" },
  opts = {},
  config = function(_, opts)
    require "nvim-tree".setup(opts)
  end
}
