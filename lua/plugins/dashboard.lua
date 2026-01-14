return {
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- kanagawa wave の青系カラーでハイライト設定
      vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#7E9CD8" }) -- crystalBlue
      vim.api.nvim_set_hl(0, "DashboardIcon", { fg = "#7FB4CA" }) -- springBlue
      vim.api.nvim_set_hl(0, "DashboardKey", { fg = "#E6C384" }) -- carpYellow
      vim.api.nvim_set_hl(0, "DashboardDesc", { fg = "#DCD7BA" }) -- fujiWhite
      vim.api.nvim_set_hl(0, "DashboardFooter", { fg = "#54546D" }) -- sumiInk4

      local header = {
        "",
        "",
        "",
        "",
        "         ███╗   ██╗ ██╗   ██╗ ██╗ ███╗   ███╗",
        "         ████╗  ██║ ██║   ██║ ██║ ████╗ ████║",
        "         ██╔██╗ ██║ ██║   ██║ ██║ ██╔████╔██║",
        "         ██║╚██╗██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
        "         ██║ ╚████║  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
        "         ╚═╝  ╚═══╝   ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
        "",
        "",
        "",
      }

      require("dashboard").setup({
        theme = "doom",
        config = {
          header = header,
          center = {
            {
              icon = "  ",
              icon_hl = "DashboardIcon",
              desc = "Find File",
              desc_hl = "DashboardDesc",
              key = "f",
              key_hl = "DashboardKey",
              action = function()
                Snacks.picker.files()
              end,
            },
            {
              icon = "  ",
              icon_hl = "DashboardIcon",
              desc = "Recent",
              desc_hl = "DashboardDesc",
              key = "r",
              key_hl = "DashboardKey",
              action = function()
                Snacks.picker.recent()
              end,
            },
            {
              icon = "  ",
              icon_hl = "DashboardIcon",
              desc = "Grep",
              desc_hl = "DashboardDesc",
              key = "g",
              key_hl = "DashboardKey",
              action = function()
                Snacks.picker.grep()
              end,
            },
            {
              icon = "  ",
              icon_hl = "DashboardIcon",
              desc = "Config",
              desc_hl = "DashboardDesc",
              key = "c",
              key_hl = "DashboardKey",
              action = "e ~/.config/nvim/",
            },
            {
              icon = "  ",
              icon_hl = "DashboardIcon",
              desc = "Quit",
              desc_hl = "DashboardDesc",
              key = "q",
              key_hl = "DashboardKey",
              action = "qa",
            },
          },
          footer = function()
            local stats = require("lazy").stats()
            return {
              "",
              stats.loaded .. "/" .. stats.count .. " plugins loaded",
            }
          end,
        },
      })
    end,
  },
}
