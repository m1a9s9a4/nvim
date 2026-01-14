return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      theme = "wave",
      transparent = true,
      background = {
        dark = "wave",
        light = "lotus",
      },
      overrides = function(colors)
        return {
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          FloatTitle = { bg = "none" },
          NormalDark = { bg = "none" },
          LazyNormal = { bg = "none" },
          MasonNormal = { bg = "none" },
        }
      end,
    },
    config = function(_, opts)
      require("kanagawa").setup(opts)
      vim.cmd.colorscheme("kanagawa")
    end,
  },
}
