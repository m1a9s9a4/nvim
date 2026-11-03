return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      -- JS/TS の ESLint は mason-lspconfig が有効化する eslint LSP が担当するので、ここでは扱わない
      lint.linters_by_ft = {
        go = { "golangcilint" },
      }

      -- 実行ファイルが無いリンターはスキップ (起動ごとに 1 回だけ通知)
      local warned = {}
      local function runnable(name)
        local def = lint.linters[name]
        local cmd = def and (type(def.cmd) == "function" and def.cmd() or def.cmd)
        if cmd and vim.fn.executable(cmd) == 1 then
          return true
        end
        if not warned[name] then
          warned[name] = true
          vim.notify(("nvim-lint: `%s` (%s) が見つからないためスキップ"):format(name, tostring(cmd)), vim.log.levels.WARN)
        end
        return false
      end

      -- golangci-lint はパッケージ全体を解析して重いので、保存時のみ実行する
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
        callback = function()
          local names = vim.tbl_filter(runnable, lint.linters_by_ft[vim.bo.filetype] or {})
          if #names > 0 then
            lint.try_lint(names)
          end
        end,
      })
    end,
  },
}
