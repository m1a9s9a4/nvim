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
  local items = {}
  for _, section in ipairs(M.sections) do
    for _, item in ipairs(section.items) do
      table.insert(items, string.format("[%s] %-15s %s", section.name, item.key, item.desc))
    end
  end

  Snacks.picker.select(items, {
    prompt = "Cheatsheet",
  }, function(_) end)
end

return M
