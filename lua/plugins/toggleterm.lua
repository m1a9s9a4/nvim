return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>t", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
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
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<C-\>]],
      direction = "float",
      float_opts = {
        border = "rounded",
        width = function()
          return math.floor(vim.o.columns * 0.85)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.8)
        end,
      },
      shell = vim.o.shell,
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      -- ターミナルモードでのキーマップ
      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*toggleterm#*",
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          vim.keymap.set("t", "<Esc>", [[<C-\><C-n><cmd>ToggleTerm<cr>]], { buffer = bufnr })
          vim.keymap.set("t", "<leader>tt", [[<cmd>ToggleTerm<cr>]], { buffer = bufnr })
        end,
      })
    end,
  },
}
