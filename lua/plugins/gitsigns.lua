return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "-" },
        topdelete = { text = "-" },
        changedelete = { text = "~" },
      },
      signs_staged = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "-" },
        topdelete = { text = "-" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local opts = { buffer = bufnr }

        -- ナビゲーション
        vim.keymap.set("n", "]c", gs.next_hunk, opts)
        vim.keymap.set("n", "[c", gs.prev_hunk, opts)

        -- アクション
        vim.keymap.set("n", "<leader>gs", gs.stage_hunk, opts)
        vim.keymap.set("n", "<leader>gr", gs.reset_hunk, opts)
        vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, opts)
        vim.keymap.set("n", "<leader>gp", gs.preview_hunk, opts)
        vim.keymap.set("n", "<leader>gb", gs.blame_line, opts)
        vim.keymap.set("n", "<leader>gd", gs.diffthis, opts)
      end,
    },
  },
}
