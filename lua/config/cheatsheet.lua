local M = {}

M.sections = {
  {
    name = "基本操作",
    items = {
      { key = "i", desc = "入力モード" },
      { key = "ESC", desc = "ノーマルモードに戻る" },
      { key = ":w", desc = "保存" },
      { key = ":q", desc = "終了" },
      { key = ":wq", desc = "保存して終了" },
      { key = "u", desc = "元に戻す (undo)" },
      { key = "Ctrl-r", desc = "やり直し (redo)" },
    },
  },
  {
    name = "移動",
    items = {
      { key = "h j k l", desc = "左 下 上 右" },
      { key = "w", desc = "次の単語" },
      { key = "b", desc = "前の単語" },
      { key = "gg", desc = "ファイル先頭" },
      { key = "G", desc = "ファイル末尾" },
      { key = "Ctrl-o", desc = "前の場所に戻る" },
      { key = "Ctrl-i", desc = "次の場所に進む" },
    },
  },
  {
    name = "LSP",
    items = {
      { key = "gd", desc = "定義へジャンプ" },
      { key = "gr", desc = "参照一覧" },
      { key = "gi", desc = "実装へジャンプ" },
      { key = "K", desc = "ドキュメント表示" },
      { key = "<leader>rn", desc = "リネーム" },
      { key = "<leader>ca", desc = "コードアクション" },
    },
  },
  {
    name = "編集",
    items = {
      { key = "yy", desc = "行をコピー" },
      { key = "dd", desc = "行を削除" },
      { key = "5dd", desc = "5行削除" },
      { key = "p", desc = "貼り付け" },
      { key = "ciw", desc = "単語を変更" },
    },
  },
  {
    name = "Snacks Picker",
    items = {
      { key = "<leader>ff", desc = "ファイル検索" },
      { key = "<leader>fg", desc = "テキスト検索" },
      { key = "<leader>fb", desc = "バッファ一覧" },
      { key = "<leader>fr", desc = "最近のファイル" },
      { key = "Enter", desc = "開く" },
      { key = "Ctrl-t", desc = "新しいタブで開く" },
      { key = "Ctrl-v", desc = "縦分割で開く" },
      { key = "Ctrl-s", desc = "横分割で開く" },
    },
  },
  {
    name = "Git / Terminal",
    items = {
      { key = "<leader>tm", desc = "ターミナル" },
      { key = "<leader>gg", desc = "lazygit" },
      { key = "]c", desc = "次の変更箇所" },
      { key = "[c", desc = "前の変更箇所" },
    },
  },
  {
    name = "Neotest",
    items = {
      { key = "<leader>tt", desc = "テスト実行" },
      { key = "<leader>tf", desc = "ファイルテスト" },
      { key = "<leader>ts", desc = "サマリー表示" },
    },
  },
}

function M.open()
  local lines = {}
  local highlights = {} -- { line, col_start, col_end, hl_group }

  for i, section in ipairs(M.sections) do
    if i > 1 then
      table.insert(lines, "")
    end
    -- セクション名
    local header = "── " .. section.name .. " ──"
    table.insert(lines, header)
    table.insert(highlights, { #lines, 0, #header, "Title" })

    for _, item in ipairs(section.items) do
      local key_col = "  " .. item.key
      local pad = string.rep(" ", math.max(1, 18 - #item.key))
      local line = key_col .. pad .. item.desc
      table.insert(lines, line)
      table.insert(highlights, { #lines, 2, 2 + #item.key, "Special" })
    end
  end

  -- ウィンドウサイズ計算
  local max_width = 0
  for _, l in ipairs(lines) do
    max_width = math.max(max_width, vim.fn.strdisplaywidth(l))
  end
  local width = math.min(max_width + 4, math.floor(vim.o.columns * 0.8))
  local height = math.min(#lines, math.floor(vim.o.lines * 0.8))

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " Cheatsheet ",
    title_pos = "center",
  })

  -- ハイライト適用
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, -1, hl[4], hl[1] - 1, hl[2], hl[3])
  end

  -- q / ESC / <leader>? で閉じる
  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true })
  vim.keymap.set("n", "<leader>?", close, { buffer = buf, nowait = true })
end

return M
