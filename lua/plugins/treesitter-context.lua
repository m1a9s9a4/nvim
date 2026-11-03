return {
  {
    -- カーソルがいる関数/メソッド/型の宣言行をウィンドウ最上部に固定表示する
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
      { "<leader>cx", "<cmd>TSContext toggle<cr>", desc = "Toggle context header" },
      {
        "[x",
        function()
          require("treesitter-context").go_to_context(vim.v.count1)
        end,
        desc = "Jump to context (enclosing function)",
      },
    },
    opts = {
      enable = true,
      max_lines = 3, -- ネストが深いときに表示する最大行数 (例: struct → method)
      min_window_height = 10,
      multiline_threshold = 1, -- 宣言が複数行でも 1 行に収める
      trim_scope = "outer",
      mode = "cursor",
      separator = nil,
    },
  },
}
