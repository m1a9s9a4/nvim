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

        -- ナビゲーション (staged/unstaged 両方の hunk を対象。diff モードでは標準の ]c/[c)
        local function nav(dir)
          return function()
            if vim.wo.diff then
              vim.cmd.normal({ dir == "next" and "]c" or "[c", bang = true })
            else
              gs.nav_hunk(dir, { target = "all" })
            end
          end
        end
        vim.keymap.set("n", "]c", nav("next"), vim.tbl_extend("force", opts, { desc = "Next hunk" }))
        vim.keymap.set("n", "[c", nav("prev"), vim.tbl_extend("force", opts, { desc = "Prev hunk" }))

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
