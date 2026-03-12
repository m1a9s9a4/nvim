return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      -- lazygit 専用（これだけ toggleterm を使う）
      {
        "<leader>gg",
        function()
          local Terminal = require("toggleterm.terminal").Terminal
          local lazygit = Terminal:new({
            cmd = "lazygit",
            hidden = true,
            direction = "float",
            float_opts = { border = "rounded" },
          })
          lazygit:toggle()
        end,
        desc = "Lazygit",
      },
    },
    opts = {
      float_opts = {
        border = "rounded",
      },
    },
  },
}
