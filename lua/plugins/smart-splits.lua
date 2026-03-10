return {
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    keys = {
      -- ウィンドウ移動
      { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move to left window" },
      { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move to lower window" },
      { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move to upper window" },
      { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move to right window" },
      -- ウィンドウリサイズ
      { "<A-h>", function() require("smart-splits").resize_left() end, desc = "Resize left" },
      { "<A-j>", function() require("smart-splits").resize_down() end, desc = "Resize down" },
      { "<A-k>", function() require("smart-splits").resize_up() end, desc = "Resize up" },
      { "<A-l>", function() require("smart-splits").resize_right() end, desc = "Resize right" },
    },
    opts = {},
  },
}
