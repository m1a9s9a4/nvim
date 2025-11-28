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
