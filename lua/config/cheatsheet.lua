local M = {}

-- サイドバー状態管理
M._win = nil
M._buf = nil

M.sections = {
  {
    name = "基本操作",
    items = {
      { key = "i", desc = "入力モード" },
      { key = "a", desc = "カーソル後ろから入力" },
      { key = "A", desc = "行末から入力" },
      { key = "I", desc = "行頭から入力" },
      { key = "o / O", desc = "下/上に新しい行を作って入力" },
      { key = "ESC", desc = "ノーマルモードに戻る" },
      { key = ":w", desc = "保存" },
      { key = ":q", desc = "終了" },
      { key = ":wq", desc = "保存して終了" },
      { key = "u", desc = "元に戻す (undo)" },
      { key = "Ctrl-r", desc = "やり直し (redo)" },
      { key = ".", desc = "直前の操作を繰り返す" },
      { key = "<leader>w", desc = "保存して前に戻る" },
    },
  },
  {
    name = "移動",
    items = {
      { key = "h j k l", desc = "左 下 上 右" },
      { key = "w / b / e", desc = "次の単語 / 前の単語 / 単語末尾" },
      { key = "0 / ^ / $", desc = "行頭 / 行頭(非空白) / 行末" },
      { key = "gg / G", desc = "ファイル先頭 / 末尾" },
      { key = "Ctrl-o", desc = "前の場所に戻る" },
      { key = "Ctrl-i", desc = "次の場所に進む" },
      { key = "Ctrl-d / Ctrl-u", desc = "半ページ下 / 上" },
      { key = "%", desc = "対応する括弧にジャンプ" },
      { key = "* / #", desc = "カーソル下の単語を前方/後方検索" },
      { key = "/ / ?", desc = "前方検索 / 後方検索" },
      { key = "n / N", desc = "次 / 前の検索結果" },
    },
  },
  {
    name = "編集",
    items = {
      { key = "yy", desc = "行をコピー" },
      { key = "dd", desc = "行を削除" },
      { key = "cc", desc = "行を変更" },
      { key = "p / P", desc = "後ろ/前に貼り付け" },
      { key = "ciw", desc = "単語を変更" },
      { key = "di(", desc = "括弧の中身を削除" },
      { key = ">> / <<", desc = "インデント / デインデント" },
      { key = "v / V / Ctrl-v", desc = "ビジュアル / 行 / ブロック選択" },
      { key = "J", desc = "行を結合" },
    },
  },
  {
    name = "Flash (ジャンプ)",
    items = {
      { key = "s", desc = "Flash ジャンプ (文字入力→候補に飛ぶ)" },
      { key = "S", desc = "Flash Treesitter (構文ノード選択)" },
    },
  },
  {
    name = "Surround (囲み文字)",
    items = {
      { key = "sa{motion}{char}", desc = '追加 (例: saiw" → 単語を""で囲む)' },
      { key = "sd{char}", desc = '削除 (例: sd" → ""を除去)' },
      { key = "sr{old}{new}", desc = "置換 (例: sr\"' → \"→'に変更)" },
    },
  },
  {
    name = "Text Objects (構造的選択)",
    items = {
      { key = "af / if", desc = "関数の外側 / 内側 (例: daf で関数削除)" },
      { key = "ac / ic", desc = "クラス/構造体の外側 / 内側" },
      { key = "aa / ia", desc = "引数の外側 / 内側 (例: cia で引数変更)" },
      { key = "]f / [f", desc = "次 / 前の関数にジャンプ" },
      { key = "]C / [C", desc = "次 / 前のクラスにジャンプ" },
      { key = "<leader>sn", desc = "引数を次と入れ替え" },
      { key = "<leader>sp", desc = "引数を前と入れ替え" },
    },
  },
  {
    name = "LSP",
    items = {
      { key = "gd", desc = "定義へジャンプ" },
      { key = "gr", desc = "参照一覧" },
      { key = "gi", desc = "実装へジャンプ" },
      { key = "gy", desc = "型定義へジャンプ" },
      { key = "K", desc = "ドキュメント表示 (ホバー)" },
      { key = "<leader>rn", desc = "リネーム" },
      { key = "<leader>ca", desc = "コードアクション" },
      { key = "<leader>cf", desc = "フォーマット" },
      { key = "<leader>cx", desc = "最上部の関数名ヘッダー (context) 表示トグル" },
      { key = "[x", desc = "囲んでいる関数の先頭へジャンプ" },
    },
  },
  {
    name = "Review (Claude Code)",
    items = {
      { key = "<leader>rc", desc = "行/選択範囲にレビューコメント" },
      { key = "<leader>rd", desc = "カーソル行のコメントを削除" },
      { key = "<leader>rv", desc = "行/選択範囲を reviewed ✓ にトグル" },
      { key = "<leader>rV", desc = "ファイル全体を reviewed ✓ にトグル" },
      { key = "<leader>rl", desc = "コメント/reviewed 一覧 (quickfix)" },
      { key = "<leader>rs", desc = "コメントを Claude Code に送信" },
      { key = "<leader>rx", desc = "コメントを全破棄 (履歴には残る)" },
      { key = "<leader>rX", desc = "レビュー完了: コメントと reviewed を全消去 (履歴に保存)" },
      { key = "<leader>rh", desc = "送信履歴を見る" },
      { key = "<leader>rR", desc = "過去の送信分を再送 (送信先を選択)" },
      { key = "<leader>rp", desc = "送信先 Claude ペインを選択" },
    },
  },
  {
    name = "Diagnostics (trouble)",
    items = {
      { key = "<leader>xx", desc = "全診断トグル" },
      { key = "<leader>xX", desc = "現バッファの診断" },
      { key = "<leader>xq", desc = "Quickfix リスト" },
      { key = "<leader>xs", desc = "シンボル一覧" },
    },
  },
  {
    name = "Finder (Snacks Picker)",
    items = {
      { key = "<leader>ff", desc = "ファイル検索" },
      { key = "<leader>fg", desc = "テキスト検索 (grep)" },
      { key = "<leader>fb", desc = "バッファ一覧" },
      { key = "<leader>fr", desc = "最近のファイル" },
      { key = "<leader>fh", desc = "ヘルプ検索" },
      { key = "<leader>fc", desc = "コマンド一覧" },
      { key = "<leader>fs", desc = "LSP シンボル (現ファイル)" },
      { key = "<leader>fS", desc = "LSP シンボル (ワークスペース)" },
      { key = "<leader>ft", desc = "TODO 一覧" },
      { key = "<leader>:", desc = "コマンド履歴" },
      { key = "<leader>/", desc = "開いているバッファ内検索" },
      { key = "Enter", desc = "Picker: 開く" },
      { key = "Ctrl-t / v / s", desc = "Picker: タブ / 縦分割 / 横分割" },
    },
  },
  {
    name = "Neo-tree (ファイルツリー)",
    items = {
      { key = "<leader>e", desc = "ファイルツリー トグル" },
      { key = "<leader>ge", desc = "Git ステータスツリー トグル" },
      { key = "Enter", desc = "ファイルを開く" },
      { key = "P", desc = "プレビュー" },
      { key = "a", desc = "新規ファイル/フォルダ作成" },
      { key = "d", desc = "削除" },
      { key = "r", desc = "リネーム" },
      { key = "c / m / p", desc = "コピー / 移動 / 貼り付け" },
      { key = "q", desc = "ツリーを閉じる" },
      { key = "Ctrl-o", desc = "ファイルを開いた後に戻る" },
    },
  },
  {
    name = "Git",
    items = {
      { key = "<leader>gg", desc = "Lazygit を開く" },
      { key = "<leader>gs", desc = "ステージ (hunk)" },
      { key = "<leader>gr", desc = "リセット (hunk)" },
      { key = "<leader>gu", desc = "ステージ取消" },
      { key = "<leader>gp", desc = "プレビュー (hunk)" },
      { key = "<leader>gb", desc = "Blame (行)" },
      { key = "<leader>gd", desc = "Diff" },
      { key = "<leader>gf", desc = "Git ファイル検索" },
      { key = "<leader>gl", desc = "Git ログ" },
      { key = "]c / [c", desc = "次/前の変更箇所 (hunk)" },
    },
  },
  {
    name = "Test (Neotest)",
    items = {
      { key = "<leader>tt", desc = "カーソル近くのテスト実行" },
      { key = "<leader>tf", desc = "ファイル全テスト" },
      { key = "<leader>ta", desc = "全テスト" },
      { key = "<leader>ts", desc = "サマリーパネル" },
      { key = "<leader>to", desc = "テスト出力" },
      { key = "<leader>tp", desc = "出力パネル" },
      { key = "<leader>tl", desc = "前回のテスト再実行" },
      { key = "<leader>tw", desc = "ファイルテスト監視" },
    },
  },
  {
    name = "Debug (DAP)",
    items = {
      { key = "<leader>dc", desc = "デバッグ開始/続行" },
      { key = "<leader>db", desc = "ブレークポイント トグル" },
      { key = "<leader>dB", desc = "条件付きブレークポイント" },
      { key = "<leader>dn", desc = "ステップオーバー (次の行)" },
      { key = "<leader>di", desc = "ステップイン (関数に入る)" },
      { key = "<leader>do", desc = "ステップアウト (関数から出る)" },
      { key = "<leader>dt", desc = "デバッグ終了" },
      { key = "<leader>du", desc = "デバッグ UI トグル" },
      { key = "<leader>de", desc = "変数を評価 (n/v)" },
      { key = "<leader>dr", desc = "REPL を開く" },
    },
  },
  {
    name = "Claude Code (AI)",
    items = {
      { key = "<leader>ac", desc = "Claude パネル トグル" },
      { key = "<leader>af", desc = "Claude にフォーカス" },
      { key = "<leader>as", desc = "選択範囲を Claude に送信 (v)" },
      { key = "<leader>ab", desc = "現バッファを Claude に追加" },
      { key = "<leader>ay", desc = "ファイル:行番号をコピー" },
      { key = "<leader>ap", desc = "ファイル:行番号を隣ペインに送信" },
    },
  },
  {
    name = "TODO コメント",
    items = {
      { key = "]t / [t", desc = "次/前の TODO にジャンプ" },
      { key = "<leader>ft", desc = "TODO 一覧 (Quickfix)" },
    },
  },
  {
    name = "ウィンドウ / ペイン",
    items = {
      { key = "Ctrl-h/j/k/l", desc = "ペイン移動 (Neovim ↔ WezTerm)" },
      { key = "Ctrl-h/j/k/l", desc = "ターミナル(Claude等)からも移動可" },
      { key = "Alt-h/j/k/l", desc = "ペイン リサイズ" },
      { key = "<leader>e", desc = "Neo-tree ↔ エディタ 行き来" },
      { key = "Ctrl-o", desc = "Neo-tree で開いた後エディタに戻る" },
      { key = "<leader>?", desc = "このチートシートを表示" },
    },
  },
}

--- バッファにチートシート内容を書き込む
local function render_buffer(buf)
  local lines = {}
  local highlights = {} -- { line (0-indexed), col_start, col_end, hl_group }

  for i, section in ipairs(M.sections) do
    if i > 1 then
      table.insert(lines, "")
    end

    -- セクションヘッダー
    local header = "── " .. section.name .. " ──"
    local header_line = #lines
    table.insert(lines, header)
    table.insert(highlights, { header_line, 0, #header, "Title" })

    -- 各アイテム
    for _, item in ipairs(section.items) do
      local key_col_start = 2
      local key_text = item.key
      local line = "  " .. key_text .. string.rep(" ", math.max(1, 20 - #key_text)) .. item.desc
      local line_nr = #lines
      table.insert(lines, line)
      table.insert(highlights, { line_nr, key_col_start, key_col_start + #key_text, "Special" })
    end
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  -- ハイライト適用
  local ns = vim.api.nvim_create_namespace("cheatsheet")
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, ns, hl[4], hl[1], hl[2], hl[3])
  end
end

--- バッファを作成または再利用する
local function get_or_create_buf()
  if M._buf and vim.api.nvim_buf_is_valid(M._buf) then
    return M._buf
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "cheatsheet"

  render_buffer(buf)

  -- バッファ内キーマップ
  vim.keymap.set("n", "q", function()
    M.close()
  end, { buffer = buf, nowait = true, desc = "Close cheatsheet" })
  vim.keymap.set("n", "<leader>?", function()
    M.close()
  end, { buffer = buf, nowait = true, desc = "Close cheatsheet" })

  M._buf = buf
  return buf
end

function M.close()
  if M._win and vim.api.nvim_win_is_valid(M._win) then
    vim.api.nvim_win_close(M._win, true)
  end
  M._win = nil
end

function M.toggle()
  -- ウィンドウが存在して有効 → 閉じる
  if M._win and vim.api.nvim_win_is_valid(M._win) then
    M.close()
    return
  end

  -- 右側にサイドバーを開く
  local buf = get_or_create_buf()

  vim.cmd("botright vsplit")
  M._win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(M._win, buf)

  -- ウィンドウ設定
  vim.api.nvim_win_set_width(M._win, 45)
  vim.wo[M._win].winfixwidth = true
  vim.wo[M._win].number = false
  vim.wo[M._win].relativenumber = false
  vim.wo[M._win].signcolumn = "no"
  vim.wo[M._win].foldcolumn = "0"
  vim.wo[M._win].wrap = false
  vim.wo[M._win].spell = false
  vim.wo[M._win].cursorline = true

  -- 元のウィンドウにフォーカスを戻す
  vim.cmd("wincmd p")
end

-- open() は toggle() のエイリアス（keymaps.lua の変更不要）
M.open = M.toggle

return M
