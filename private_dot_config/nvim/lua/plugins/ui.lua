return {
  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true, -- Enable this to disable setting the background color
    },
    config = function(_, opts)
      require "nord".setup(opts)
    end,
  },
}
