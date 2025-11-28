return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "fredrikaverpil/neotest-golang",
    },
    keys = {
      {
        "<leader>tt",
        function()
          require("neotest").run.run()
        end,
        desc = "Run nearest test",
      },
      {
        "<leader>tf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run file tests",
      },
      {
        "<leader>ta",
        function()
          require("neotest").run.run(vim.fn.getcwd())
        end,
        desc = "Run all tests",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Toggle summary",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true, auto_close = true })
        end,
        desc = "Show output",
      },
      {
        "<leader>tp",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Toggle output panel",
      },
      {
        "<leader>tl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Run last test",
      },
      {
        "<leader>tw",
        function()
          require("neotest").watch.toggle(vim.fn.expand("%"))
        end,
        desc = "Watch file tests",
      },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-golang")(),
        },
        summary = {
          open = "botright vsplit | vertical resize 50",
          mappings = {
            expand = { "<CR>", "<2-LeftMouse>" },
            expand_all = "e",
            output = "o",
            short = "O",
            attach = "a",
            jumpto = "i",
            stop = "u",
            run = "r",
            mark = "m",
            run_marked = "R",
            clear_marked = "M",
            target = "t",
            clear_target = "T",
          },
        },
        output = {
          open_on_run = false,
        },
        output_panel = {
          open = "botright split | resize 15",
        },
        icons = {
          passed = "✓",
          failed = "✗",
          running = "⟳",
          skipped = "○",
          unknown = "?",
        },
        status = {
          virtual_text = true,
          signs = true,
        },
        floating = {
          border = "rounded",
          max_height = 0.6,
          max_width = 0.8,
        },
      })
    end,
  },
}
