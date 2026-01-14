-- ウィンドウ間の移動
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- チートシートを開く
vim.keymap.set("n", "<leader>?", function()
  require("config.cheatsheet").open()
end, { desc = "Cheatsheet" })
-- 保存して前に戻る
vim.keymap.set("n", "<leader>w", "<cmd>w<cr><C-o>", { desc = "Save and go back" })

-- :Cheat コマンドで開く
vim.api.nvim_create_user_command("Cheat", function()
  require("config.cheatsheet").open()
end, {})
