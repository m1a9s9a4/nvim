-- ウィンドウ間の移動は smart-splits.nvim で管理 (plugins/smart-splits.lua)
-- ターミナルモードでもCtrl+hjklでウィンドウ移動 (Claude Code等)
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-h>]], { desc = "Move to left window" })
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-j>]], { desc = "Move to lower window" })
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-k>]], { desc = "Move to upper window" })
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-l>]], { desc = "Move to right window" })

-- チートシートを開く
vim.keymap.set("n", "<leader>?", function()
  require("config.cheatsheet").open()
end, { desc = "Cheatsheet" })
-- 保存して前に戻る
vim.keymap.set("n", "<leader>w", "<cmd>w<cr><C-o>", { desc = "Save and go back" })

-- ファイル:行番号をクリップボードにコピー
vim.keymap.set("n", "<leader>ay", function()
  local path = vim.fn.expand("%:.")
  local line = vim.fn.line(".")
  local location = path .. ":" .. line
  vim.fn.setreg("+", location)
  vim.notify(location, vim.log.levels.INFO, { title = "Copied" })
end, { desc = "Copy file:line to clipboard" })

-- ファイル:行番号を Claude Code のペイン (Herdr / WezTerm) に送信
vim.keymap.set("n", "<leader>ap", function()
  local location = vim.fn.expand("%:.") .. ":" .. vim.fn.line(".")
  require("config.review").send_raw(location, function(t)
    vim.notify("Sent: " .. location .. " → " .. t.label, vim.log.levels.INFO)
  end)
end, { desc = "Send file:line to Claude Code pane" })

-- :Cheat コマンドで開く
vim.api.nvim_create_user_command("Cheat", function()
  require("config.cheatsheet").open()
end, {})
