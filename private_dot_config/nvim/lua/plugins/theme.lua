return {
  {
    'AlexvZyl/nordic.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
    config = function(_, opts)
      require 'nordic'.setup(opts)
      require 'nordic'.load()
    end
  }
}
