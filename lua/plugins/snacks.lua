-- LSP picker wrapper: include the cursor location (so `gd` on a definition does not
-- report "No results"), and explain when no LSP client is attached to the buffer.
local function lsp_pick(source, method)
  return function()
    local buf = vim.api.nvim_get_current_buf()
    local attached = vim.lsp.get_clients({ bufnr = buf })
    local capable = vim.tbl_filter(function(c)
      return c:supports_method(method, buf)
    end, attached)
    if #capable == 0 then
      local names = vim.tbl_map(function(c)
        return c.name
      end, attached)
      vim.notify(
        ("No LSP client supports %s here (ft=%s, attached: %s)"):format(
          method,
          vim.bo[buf].filetype,
          #names > 0 and table.concat(names, ", ") or "none"
        ),
        vim.log.levels.WARN
      )
      return
    end
    Snacks.picker[source]({ include_current = true })
  end
end

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      -- ファイル検索
      {
        "<leader>ff",
        function()
          Snacks.picker.files({ hidden = true })
        end,
        desc = "Find Files",
      },
      {
        "<leader>fg",
        function()
          Snacks.picker.grep()
        end,
        desc = "Grep",
      },
      {
        "<leader>fb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>fh",
        function()
          Snacks.picker.help()
        end,
        desc = "Help",
      },
      {
        "<leader>fr",
        function()
          Snacks.picker.recent()
        end,
        desc = "Recent Files",
      },
      {
        "<leader>fc",
        function()
          Snacks.picker.commands()
        end,
        desc = "Commands",
      },
      {
        "<leader>fs",
        function()
          Snacks.picker.lsp_symbols()
        end,
        desc = "LSP Symbols",
      },
      {
        "<leader>fS",
        function()
          Snacks.picker.lsp_workspace_symbols()
        end,
        desc = "Workspace Symbols",
      },
      -- Git
      {
        "<leader>gf",
        function()
          Snacks.picker.git_files()
        end,
        desc = "Git Files",
      },
      {
        "<leader>gl",
        function()
          Snacks.picker.git_log()
        end,
        desc = "Git Log",
      },
      {
        "<leader>gs",
        function()
          Snacks.picker.git_status()
        end,
        desc = "Git Status",
      },
      -- LSP
      {
        "gd",
        lsp_pick("lsp_definitions", "textDocument/definition"),
        desc = "Go to Definition",
      },
      {
        "gr",
        lsp_pick("lsp_references", "textDocument/references"),
        desc = "References",
      },
      {
        "gi",
        lsp_pick("lsp_implementations", "textDocument/implementation"),
        desc = "Implementations",
      },
      {
        "gy",
        lsp_pick("lsp_type_definitions", "textDocument/typeDefinition"),
        desc = "Type Definitions",
      },
      -- その他
      {
        "<leader>:",
        function()
          Snacks.picker.command_history()
        end,
        desc = "Command History",
      },
      {
        "<leader>/",
        function()
          Snacks.picker.grep_buffers()
        end,
        desc = "Grep Buffers",
      },
    },
    opts = {
      picker = {
        enabled = true,
        layout = {
          preset = "default",
        },
        win = {
          input = {
            keys = {
              ["<C-t>"] = { "edit_tab", mode = { "i", "n" } },
              ["<C-v>"] = { "edit_vsplit", mode = { "i", "n" } },
              ["<C-s>"] = { "edit_split", mode = { "i", "n" } },
              ["<C-x>"] = { "edit_split", mode = { "i", "n" } },
            },
          },
        },
      },
      bigfile = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },
}
