return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
        "go",
        "gomod",
        "gosum",
        "typescript",
        "tsx",
        "javascript",
        "html",
        "css",
        "json",
        "yaml",
        "lua",
        "markdown",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    -- main ブランチ (新実装): モジュール設定ではなく setup + 自前キーマップで有効化する
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })
      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")
      local map = vim.keymap.set

      local function sel(query, desc)
        map({ "x", "o" }, query[1], function()
          select.select_textobject(query[2], "textobjects")
        end, { desc = desc })
      end
      sel({ "af", "@function.outer" }, "outer function")
      sel({ "if", "@function.inner" }, "inner function")
      sel({ "ac", "@class.outer" }, "outer class")
      sel({ "ic", "@class.inner" }, "inner class")
      sel({ "aa", "@parameter.outer" }, "outer argument")
      sel({ "ia", "@parameter.inner" }, "inner argument")

      local function mv(lhs, fn, query, desc)
        map({ "n", "x", "o" }, lhs, function()
          fn(query, "textobjects")
        end, { desc = desc })
      end
      mv("]f", move.goto_next_start, "@function.outer", "Next function")
      mv("[f", move.goto_previous_start, "@function.outer", "Previous function")
      -- ]c/[c は gitsigns の hunk 移動に使うので、クラスは大文字
      mv("]C", move.goto_next_start, "@class.outer", "Next class")
      mv("[C", move.goto_previous_start, "@class.outer", "Previous class")

      map("n", "<leader>sn", function()
        swap.swap_next("@parameter.inner")
      end, { desc = "Swap next argument" })
      map("n", "<leader>sp", function()
        swap.swap_previous("@parameter.inner")
      end, { desc = "Swap previous argument" })
    end,
  },
}
