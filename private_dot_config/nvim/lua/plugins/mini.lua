return {
  {
    'echasnovski/mini.animate',
    event = "VeryLazy",
    opts = {
      resize = {
        enable = false
      },
      open = {
        enable = false
      },
      close = {
        enable = false
      }
    },
    config = function(_, opts)
      require "mini.animate".setup(opts)
    end
  },
  {
    "echasnovski/mini.bufremove",
    lazy = true,
  },
}
