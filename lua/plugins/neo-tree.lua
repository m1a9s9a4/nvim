return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "NeoTree Files" },
    { "<leader>ge", "<cmd>Neotree toggle git_status<cr>", desc = "NeoTree Git Status" },
  },
  opts = {
    source_selector = {
      winbar = true,
      sources = {
        { source = "filesystem", display_name = " Files" },
        { source = "git_status", display_name = " Git" },
      },
    },
    filesystem = {
      follow_current_file = {
        enabled = true,
      },
      use_libuv_file_watcher = true,
    },
    event_handlers = {
      {
        event = "neo_tree_buffer_enter",
        handler = function()
          vim.opt_local.statusline =
            "%#Special# ⏎%#Comment# Open  %#Special#q%#Comment# Close  %#Special#P%#Comment# Preview  %#Special#a%#Comment# Add  %#Special#d%#Comment# Del  %#Special#r%#Comment# Rename  %#Special#⌃o%#Comment# Back"
        end,
      },
    },
  },
}
