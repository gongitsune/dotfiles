return {
  {
    'AlexvZyl/nordic.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      -- Enable general editor background transparency.
      transparent_bg = true,
    },
    config = function(_, opts)
      require 'nordic'.setup(opts)
      require 'nordic'.load()
    end
  }
}
