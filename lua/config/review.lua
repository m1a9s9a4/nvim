-- Line-anchored review comments that are sent to a Claude Code pane in one batch,
-- plus "reviewed" check marks for code that was looked at and found fine.
--
-- Comments and reviewed marks are attached to buffer lines via extmarks so they
-- follow edits. Sending pastes the formatted batch into a WezTerm pane running
-- `claude` (bracketed paste, so the prompt is not submitted until Enter is pressed).
--
-- Persistence (per git worktree, under stdpath("data")/claude-review/<repo>-<hash>/):
--   pending.json        unsent comments + reviewed marks, autosaved on every change
--                       and restored on startup
--   history/<time>.md   every sent (or discarded) batch, for looking back later
local M = {}

local ns = vim.api.nvim_create_namespace("claude_review")

---@class ReviewMark
---@field bufnr integer|nil  nil while the buffer is not loaded
---@field mark integer|nil   extmark id (tracks the line across edits)
---@field file string        path relative to the worktree root
---@field lnum integer       snapshot in case the buffer is gone
---@field end_lnum integer
---@field lines string[]|nil snapshot of the code (comments only)
---@field comment string|nil
---@field whole boolean|nil  reviewed: whole file
---@field filetype string|nil
---@field created string

---@type ReviewMark[]  pending comments
M.comments = {}
---@type ReviewMark[]  code marked as reviewed / OK
M.reviewed = {}

----------------------------------------------------------------------
-- Storage location
----------------------------------------------------------------------

local function worktree_root()
  local out = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()
  if out.code == 0 and out.stdout and out.stdout ~= "" then
    return (out.stdout:gsub("%s+$", ""))
  end
  return vim.fn.getcwd()
end

local root = worktree_root()

local function store_dir()
  local slug = vim.fn.fnamemodify(root, ":t") .. "-" .. vim.fn.sha256(root):sub(1, 8)
  return vim.fn.stdpath("data") .. "/claude-review/" .. slug
end

local function pending_path()
  return store_dir() .. "/pending.json"
end

local function history_dir()
  return store_dir() .. "/history"
end

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------

local function now()
  return os.date("%Y-%m-%d %H:%M:%S")
end

local function relpath(bufnr)
  local abs = vim.api.nvim_buf_get_name(bufnr)
  -- gitsigns diff buffers look like gitsigns://<gitdir>//<rev>:<path>; use <path>.
  local gs = abs:match("^gitsigns://.-//(.*)$")
  if gs then
    local path = gs:match("^:?[^:]*:(.*)$")
    if path then
      return path
    end
  end
  if abs:sub(1, #root + 1) == root .. "/" then
    return abs:sub(#root + 2)
  end
  return vim.fn.fnamemodify(abs, ":.")
end

local function abspath(file)
  if file:sub(1, 1) == "/" then
    return file
  end
  return root .. "/" .. file
end

local function first_line(s)
  return (s:gsub("\n.*", ""))
end

local function buf_loaded(c)
  return c.bufnr ~= nil and vim.api.nvim_buf_is_valid(c.bufnr) and vim.api.nvim_buf_is_loaded(c.bufnr)
end

local function place_mark(bufnr, c)
  local last = vim.api.nvim_buf_line_count(bufnr)
  local lnum = math.max(1, math.min(c.lnum, last))
  local end_lnum = math.max(lnum, math.min(c.end_lnum, last))
  local opts
  if c.comment then
    opts = {
      sign_text = "R",
      sign_hl_group = "DiagnosticInfo",
      virt_text = { { " 💬 " .. first_line(c.comment), "Comment" } },
      virt_text_pos = "eol",
    }
  else
    opts = {
      sign_text = "✓",
      sign_hl_group = "DiagnosticOk",
      virt_text = { { c.whole and " ✓ file reviewed" or " ✓ reviewed", "DiagnosticOk" } },
      virt_text_pos = "eol",
    }
  end
  if end_lnum > lnum and not c.whole then
    opts.end_row = end_lnum - 1
  end
  return vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, 0, opts)
end

-- Resolve the current 1-based line range of a mark, falling back to the snapshot.
local function resolve(c)
  if buf_loaded(c) and c.mark then
    local pos = vim.api.nvim_buf_get_extmark_by_id(c.bufnr, ns, c.mark, { details = true })
    if pos and pos[1] then
      local row = pos[1] + 1
      local end_row = row
      if pos[3] and pos[3].end_row and pos[3].end_row + 1 > row then
        end_row = pos[3].end_row + 1
      end
      local lines = c.lines and vim.api.nvim_buf_get_lines(c.bufnr, row - 1, end_row, false) or nil
      return row, end_row, lines
    end
  end
  return c.lnum, c.end_lnum, c.lines
end

-- Refresh the snapshot fields from the live extmark (no-op when the buffer is gone).
local function snapshot(c)
  c.lnum, c.end_lnum, c.lines = resolve(c)
end

local function del_mark(c)
  if buf_loaded(c) and c.mark then
    vim.api.nvim_buf_del_extmark(c.bufnr, ns, c.mark)
  end
  c.bufnr, c.mark = nil, nil
end

local function all_marks()
  local out = {}
  vim.list_extend(out, M.comments)
  vim.list_extend(out, M.reviewed)
  return out
end

----------------------------------------------------------------------
-- Persistence
----------------------------------------------------------------------

local function serialize(c)
  snapshot(c)
  return {
    file = c.file,
    lnum = c.lnum,
    end_lnum = c.end_lnum,
    lines = c.lines,
    comment = c.comment,
    whole = c.whole,
    filetype = c.filetype,
    created = c.created,
  }
end

local function save()
  vim.fn.mkdir(store_dir(), "p")
  if #M.comments == 0 and #M.reviewed == 0 then
    vim.fn.delete(pending_path())
    return
  end
  local data = {
    root = root,
    comments = vim.tbl_map(serialize, M.comments),
    reviewed = vim.tbl_map(serialize, M.reviewed),
  }
  vim.fn.writefile({ vim.json.encode(data) }, pending_path())
end

local function load()
  local path = pending_path()
  if vim.fn.filereadable(path) == 0 then
    return
  end
  local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
  if not ok or type(decoded) ~= "table" then
    vim.notify("claude-review: could not parse " .. path, vim.log.levels.WARN)
    return
  end
  M.comments = type(decoded.comments) == "table" and decoded.comments or {}
  M.reviewed = type(decoded.reviewed) == "table" and decoded.reviewed or {}
end

local function build_message()
  local parts = { "以下のレビューコメントに対応してください。", "" }
  for i, c in ipairs(M.comments) do
    local s, e, lines = resolve(c)
    local loc = e > s and ("%s:%d-%d"):format(c.file, s, e) or ("%s:%d"):format(c.file, s)
    parts[#parts + 1] = ("### %d. %s"):format(i, loc)
    parts[#parts + 1] = "```" .. (buf_loaded(c) and vim.bo[c.bufnr].filetype or c.filetype or "")
    vim.list_extend(parts, lines or {})
    parts[#parts + 1] = "```"
    parts[#parts + 1] = c.comment
    parts[#parts + 1] = ""
  end
  return table.concat(parts, "\n")
end

local function reviewed_label(c)
  local s, e = resolve(c)
  if c.whole then
    return c.file .. " (whole file)"
  end
  return e > s and ("%s:%d-%d"):format(c.file, s, e) or ("%s:%d"):format(c.file, s)
end

---@param kind "sent"|"discarded"|"finished"
---@return string path
local function archive(kind, message)
  vim.fn.mkdir(history_dir(), "p")
  local path = ("%s/%s-%s.md"):format(history_dir(), os.date("%Y-%m-%d_%H%M%S"), kind)
  local out = {
    ("<!-- %s | %s | %d comment(s) | %s -->"):format(kind, root, #M.comments, now()),
    "",
  }
  vim.list_extend(out, vim.split(message, "\n", { plain = true }))
  if #M.reviewed > 0 then
    out[#out + 1] = "---"
    out[#out + 1] = ""
    out[#out + 1] = "## Reviewed (OK)"
    out[#out + 1] = ""
    for _, c in ipairs(M.reviewed) do
      out[#out + 1] = "- ✓ " .. reviewed_label(c)
    end
    out[#out + 1] = ""
  end
  vim.fn.writefile(out, path)
  return path
end

----------------------------------------------------------------------
-- Attaching restored marks to buffers
----------------------------------------------------------------------

local function attach(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return
  end
  for _, c in ipairs(all_marks()) do
    if not buf_loaded(c) and abspath(c.file) == name then
      c.bufnr = bufnr
      c.mark = place_mark(bufnr, c)
    end
  end
end

local function detach(bufnr)
  for _, c in ipairs(all_marks()) do
    if c.bufnr == bufnr then
      snapshot(c)
      c.bufnr, c.mark = nil, nil
    end
  end
end

----------------------------------------------------------------------
-- Comments
----------------------------------------------------------------------

function M.add(line1, line2)
  local bufnr = vim.api.nvim_get_current_buf()
  local file = relpath(bufnr)
  local range = line2 > line1 and ("%d-%d"):format(line1, line2) or tostring(line1)
  vim.ui.input({ prompt = ("Review %s:%s > "):format(file, range) }, function(text)
    if not text or text == "" then
      return
    end
    local c = {
      bufnr = bufnr,
      file = file,
      lnum = line1,
      end_lnum = line2,
      lines = vim.api.nvim_buf_get_lines(bufnr, line1 - 1, line2, false),
      comment = text,
      filetype = vim.bo[bufnr].filetype,
      created = now(),
    }
    c.mark = place_mark(bufnr, c)
    table.insert(M.comments, c)
    save()
    vim.notify(("Review comment added (%d pending)"):format(#M.comments))
  end)
end

function M.remove_at_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local cur = vim.fn.line(".")
  for i = #M.comments, 1, -1 do
    local c = M.comments[i]
    if c.bufnr == bufnr then
      local s, e = resolve(c)
      if cur >= s and cur <= e then
        del_mark(c)
        table.remove(M.comments, i)
        save()
        vim.notify(("Review comment removed (%d pending)"):format(#M.comments))
        return
      end
    end
  end
  vim.notify("No review comment on this line", vim.log.levels.WARN)
end

local function drop_comments()
  for _, c in ipairs(M.comments) do
    del_mark(c)
  end
  M.comments = {}
  save()
end

-- Discard pending comments; a copy is still kept in history. Reviewed marks are kept.
function M.clear()
  if #M.comments == 0 then
    vim.notify("No review comments to discard", vim.log.levels.WARN)
    return
  end
  local n = #M.comments
  local path = archive("discarded", build_message())
  drop_comments()
  vim.notify(("Discarded %d review comment(s). Archived to %s"):format(n, path))
end

function M.list()
  local items = {}
  for _, c in ipairs(M.comments) do
    local s = resolve(c)
    items[#items + 1] = { filename = abspath(c.file), lnum = s, text = "💬 " .. first_line(c.comment) }
  end
  for _, c in ipairs(M.reviewed) do
    local s = resolve(c)
    items[#items + 1] = { filename = abspath(c.file), lnum = s, text = "✓ " .. (c.whole and "file reviewed" or "reviewed") }
  end
  vim.fn.setqflist({}, " ", { title = "Claude review", items = items })
  vim.cmd.copen()
end

----------------------------------------------------------------------
-- Reviewed (OK) marks
----------------------------------------------------------------------

-- Toggle a reviewed mark on line1..line2 of the current buffer (or the whole file).
local function toggle_reviewed(line1, line2, whole)
  local bufnr = vim.api.nvim_get_current_buf()
  local file = relpath(bufnr)
  for i = #M.reviewed, 1, -1 do
    local c = M.reviewed[i]
    if c.file == file then
      local s, e = resolve(c)
      local hit = whole and c.whole or (not whole and not c.whole and line1 <= e and s <= line2)
      if hit then
        del_mark(c)
        table.remove(M.reviewed, i)
        save()
        vim.notify("Reviewed mark removed: " .. file)
        return
      end
    end
  end
  local c = {
    bufnr = bufnr,
    file = file,
    lnum = whole and 1 or line1,
    end_lnum = whole and vim.api.nvim_buf_line_count(bufnr) or line2,
    whole = whole or nil,
    created = now(),
  }
  c.mark = place_mark(bufnr, c)
  table.insert(M.reviewed, c)
  save()
  vim.notify(("Marked as reviewed: %s (%d reviewed)"):format(reviewed_label(c), #M.reviewed))
end

function M.toggle_reviewed_range(line1, line2)
  toggle_reviewed(line1, line2, false)
end

function M.toggle_reviewed_file()
  toggle_reviewed(1, 1, true)
end

function M.reset_reviewed()
  local n = #M.reviewed
  for _, c in ipairs(M.reviewed) do
    del_mark(c)
  end
  M.reviewed = {}
  save()
  vim.notify(("Cleared %d reviewed mark(s)"):format(n))
end

-- Review finished: archive whatever is left (comments + reviewed marks) and clear everything.
function M.finish()
  local nc, nr = #M.comments, #M.reviewed
  if nc == 0 and nr == 0 then
    vim.notify("Nothing to finish: no comments or reviewed marks", vim.log.levels.WARN)
    return
  end
  local path = archive("finished", nc > 0 and build_message() or "(no pending comments)")
  for _, c in ipairs(M.comments) do
    del_mark(c)
  end
  for _, c in ipairs(M.reviewed) do
    del_mark(c)
  end
  M.comments, M.reviewed = {}, {}
  save()
  vim.notify(("Review finished: cleared %d comment(s), %d reviewed mark(s). Archived to %s"):format(nc, nr, path))
end

----------------------------------------------------------------------
-- History
----------------------------------------------------------------------

-- Browse archived batches for this worktree (newest first).
function M.history()
  local dir = history_dir()
  local files = vim.fn.glob(dir .. "/*.md", false, true)
  if #files == 0 then
    vim.notify("No review history for " .. root, vim.log.levels.WARN)
    return
  end
  table.sort(files, function(a, b)
    return a > b
  end)
  if package.loaded["snacks"] and Snacks.picker then
    Snacks.picker.files({ cwd = dir, title = "Claude review history", sort = { fields = { "file:desc" } } })
    return
  end
  vim.ui.select(files, {
    prompt = "Claude review history:",
    format_item = function(f)
      return vim.fn.fnamemodify(f, ":t:r")
    end,
  }, function(f)
    if f then
      vim.cmd.edit(f)
    end
  end)
end

----------------------------------------------------------------------
-- Target resolution: Claude panes in Herdr (when Neovim runs inside Herdr)
-- and in WezTerm. Herdr panes are listed first.
----------------------------------------------------------------------

---@class ReviewTarget
---@field backend "herdr"|"wezterm"
---@field id string|integer
---@field same_tab boolean
---@field adjacent boolean   wezterm only
---@field same_ws boolean    herdr only
---@field same_cwd boolean   herdr only
---@field label string

---@type ReviewTarget|nil
local target = nil

local function short_cwd(cwd)
  cwd = (cwd or ""):gsub("^file://[^/]*", "")
  return (cwd:gsub("^" .. vim.pesc(vim.env.HOME or "~"), "~"))
end

-- Herdr --------------------------------------------------------------

local function herdr_available()
  return vim.env.HERDR_ENV == "1" and vim.fn.executable("herdr") == 1
end

---@return ReviewTarget[]
local function herdr_candidates()
  if not herdr_available() then
    return {}
  end
  local out = vim.system({ "herdr", "agent", "list" }, { text = true }):wait()
  if out.code ~= 0 or not out.stdout or out.stdout == "" then
    return {}
  end
  local ok, data = pcall(vim.json.decode, out.stdout)
  if not ok or type(data) ~= "table" then
    return {}
  end
  local agents = data.result and data.result.agents or {}
  local me_pane, me_tab, me_ws = vim.env.HERDR_PANE_ID, vim.env.HERDR_TAB_ID, vim.env.HERDR_WORKSPACE_ID
  local found = {}
  for _, a in ipairs(agents) do
    if a.agent == "claude" and a.pane_id ~= me_pane then
      local t = {
        backend = "herdr",
        id = a.pane_id,
        same_tab = a.tab_id == me_tab,
        same_ws = a.workspace_id == me_ws,
        same_cwd = a.cwd == root,
        adjacent = false,
      }
      local tag = t.same_tab and " [same tab]" or (t.same_ws and " [same workspace]" or "")
      t.label = ("herdr %s%s  claude:%s  %s%s"):format(
        a.pane_id,
        tag,
        tostring(a.agent_status),
        short_cwd(a.cwd),
        a.name and ("  [" .. a.name .. "]") or ""
      )
      found[#found + 1] = t
    end
  end
  table.sort(found, function(x, y)
    if x.same_tab ~= y.same_tab then
      return x.same_tab
    end
    if x.same_cwd ~= y.same_cwd then
      return x.same_cwd
    end
    if x.same_ws ~= y.same_ws then
      return x.same_ws
    end
    return tostring(x.id) < tostring(y.id)
  end)
  return found
end

-- WezTerm ------------------------------------------------------------

local function wezterm_panes()
  if vim.fn.executable("wezterm") == 0 then
    return {}
  end
  local out = vim.system({ "wezterm", "cli", "list", "--format", "json" }, { text = true }):wait()
  if out.code ~= 0 or not out.stdout or out.stdout == "" then
    return {}
  end
  local ok, panes = pcall(vim.json.decode, out.stdout)
  return ok and panes or {}
end

local function runs_claude(tty_name)
  local tty = tty_name:gsub("^/dev/", "")
  local out = vim.system({ "ps", "-t", tty, "-o", "comm=" }, { text = true }):wait()
  if out.code ~= 0 or not out.stdout then
    return false
  end
  for line in out.stdout:gmatch("[^\n]+") do
    if line:match("/claude$") or line:match("^claude$") then
      return true
    end
  end
  return false
end

-- True when `p` shares an edge with `me` (a one-cell separator is allowed).
local function adjacent(me, p)
  local function overlaps(a0, a1, b0, b1)
    return a0 < b1 and b0 < a1
  end
  local me_r, me_b = me.left_col + me.size.cols, me.top_row + me.size.rows
  local p_r, p_b = p.left_col + p.size.cols, p.top_row + p.size.rows
  local v = overlaps(me.top_row, me_b, p.top_row, p_b)
  local h = overlaps(me.left_col, me_r, p.left_col, p_r)
  return (v and (math.abs(p.left_col - me_r) <= 1 or math.abs(me.left_col - p_r) <= 1))
    or (h and (math.abs(p.top_row - me_b) <= 1 or math.abs(me.top_row - p_b) <= 1))
end

---@return ReviewTarget[]
local function wezterm_candidates()
  local my_pane = tonumber(vim.env.WEZTERM_PANE)
  local panes = wezterm_panes()
  local me
  for _, p in ipairs(panes) do
    if p.pane_id == my_pane then
      me = p
    end
  end
  local found = {}
  for _, p in ipairs(panes) do
    if p.pane_id ~= my_pane and runs_claude(p.tty_name) then
      local t = {
        backend = "wezterm",
        id = p.pane_id,
        same_tab = me ~= nil and p.tab_id == me.tab_id,
        same_ws = false,
        same_cwd = false,
      }
      t.adjacent = me ~= nil and t.same_tab and adjacent(me, p)
      local tag = t.adjacent and " [adjacent]" or (t.same_tab and " [same tab]" or "")
      t.label = ("wezterm pane %d%s  %s  (%s)"):format(p.pane_id, tag, p.title, short_cwd(p.cwd))
      found[#found + 1] = t
    end
  end
  table.sort(found, function(x, y)
    if x.adjacent ~= y.adjacent then
      return x.adjacent
    end
    if x.same_tab ~= y.same_tab then
      return x.same_tab
    end
    return x.id < y.id
  end)
  return found
end

-- Common -------------------------------------------------------------

---@return ReviewTarget[]
local function candidates()
  local list = herdr_candidates()
  vim.list_extend(list, wezterm_candidates())
  return list
end

local function same_target(a, b)
  return a and b and a.backend == b.backend and tostring(a.id) == tostring(b.id)
end

---@param cb fun(t: ReviewTarget|nil)
---@param force_pick boolean|nil
local function resolve_target(cb, force_pick)
  local list = candidates()
  if target and not force_pick then
    for _, t in ipairs(list) do
      if same_target(t, target) then
        target = t -- refresh label/status
        return cb(target)
      end
    end
    target = nil -- the remembered pane is gone
  end
  if #list == 0 then
    vim.notify("No pane running Claude Code was found (Herdr / WezTerm)", vim.log.levels.ERROR)
    return cb(nil)
  end
  if #list == 1 and not force_pick then
    target = list[1]
    return cb(target)
  end
  -- Several Claude panes: always ask. The best guess is listed first.
  vim.ui.select(list, {
    prompt = "Send review to Claude Code pane:",
    format_item = function(t)
      return t.label
    end,
  }, function(t)
    if t then
      target = t
    end
    cb(t)
  end)
end

-- Candidate labels in priority order; handy for checking what `send` would pick.
function M.candidates()
  return vim.tbl_map(function(t)
    return t.label
  end, candidates())
end

function M.pick_target()
  resolve_target(function(t)
    if t then
      vim.notify("Review target: " .. t.label)
    end
  end, true)
end

-- Paste `text` into the target's input without submitting it, then focus the pane.
---@return boolean ok
local function send_text(t, text)
  local out
  if t.backend == "herdr" then
    -- herdr sends raw bytes; wrap in bracketed paste so newlines do not submit the prompt.
    local payload = text:find("\n", 1, true) and ("\27[200~" .. text .. "\27[201~") or text
    out = vim.system({ "herdr", "pane", "send-text", t.id, payload }, { text = true }):wait()
  else
    out = vim.system({ "wezterm", "cli", "send-text", "--pane-id", tostring(t.id) }, { stdin = text, text = true }):wait()
  end
  if out.code ~= 0 then
    -- The remembered pane may have been closed; forget it so the next send re-resolves.
    target = nil
    vim.notify(("send to %s failed: %s"):format(t.label, out.stderr or ""), vim.log.levels.ERROR)
    return false
  end
  if t.backend == "herdr" then
    vim.system({ "herdr", "agent", "focus", t.id })
  else
    vim.system({ "wezterm", "cli", "activate-pane", "--pane-id", tostring(t.id) })
  end
  return true
end

-- Send arbitrary text to the current target (used by <leader>ap etc.).
---@param text string
---@param on_sent fun(t: ReviewTarget)|nil
function M.send_raw(text, on_sent)
  resolve_target(function(t)
    if t and send_text(t, text) and on_sent then
      on_sent(t)
    end
  end)
end

function M.send()
  if #M.comments == 0 then
    vim.notify("No review comments to send", vim.log.levels.WARN)
    return
  end
  resolve_target(function(t)
    if not t then
      return
    end
    local n = #M.comments
    local message = build_message()
    if not send_text(t, message) then
      return
    end
    archive("sent", message)
    drop_comments()
    vim.notify(("Sent %d review comment(s) to %s. Press Enter there to submit."):format(n, t.label))
  end)
end

-- Extract the message part of an archived batch (drops the header and the Reviewed section).
local function history_message(path)
  local lines = vim.fn.readfile(path)
  local out = {}
  for i, l in ipairs(lines) do
    if i == 1 and l:match("^<!%-%-") then
      -- header comment
    elseif l == "---" and lines[i + 2] == "## Reviewed (OK)" then
      break
    else
      out[#out + 1] = l
    end
  end
  while out[1] == "" do
    table.remove(out, 1)
  end
  while out[#out] == "" do
    table.remove(out)
  end
  return table.concat(out, "\n")
end

-- Re-send an archived batch (e.g. after it went to the wrong pane). Always asks for the pane.
function M.resend()
  local files = vim.fn.glob(history_dir() .. "/*.md", false, true)
  if #files == 0 then
    vim.notify("No review history for " .. root, vim.log.levels.WARN)
    return
  end
  table.sort(files, function(a, b)
    return a > b
  end)
  vim.ui.select(files, {
    prompt = "Re-send which batch?",
    format_item = function(f)
      local head = vim.fn.readfile(f, "", 1)[1] or ""
      local n = head:match("(%d+) comment") or "?"
      return ("%s  (%s comments)"):format(vim.fn.fnamemodify(f, ":t:r"), n)
    end,
  }, function(f)
    if not f then
      return
    end
    local message = history_message(f)
    resolve_target(function(t)
      if not t then
        return
      end
      if send_text(t, message) then
        vim.notify(("Re-sent %s to %s. Press Enter there to submit."):format(vim.fn.fnamemodify(f, ":t"), t.label))
      end
    end, true)
  end)
end

----------------------------------------------------------------------
-- Restore + autocmds
----------------------------------------------------------------------

load()

local group = vim.api.nvim_create_augroup("claude_review", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function(ev)
    attach(ev.buf)
  end,
})
vim.api.nvim_create_autocmd("BufUnload", {
  group = group,
  callback = function(ev)
    detach(ev.buf)
  end,
})
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = group,
  callback = save,
})

-- Buffers that were already open when this module loaded.
for _, b in ipairs(vim.api.nvim_list_bufs()) do
  if vim.api.nvim_buf_is_loaded(b) then
    attach(b)
  end
end

if #M.comments > 0 or #M.reviewed > 0 then
  vim.schedule(function()
    vim.notify(("Restored %d pending comment(s), %d reviewed mark(s)"):format(#M.comments, #M.reviewed))
  end)
end

----------------------------------------------------------------------
-- Commands and keymaps
----------------------------------------------------------------------

local cmd = vim.api.nvim_create_user_command
cmd("ClaudeReviewComment", function(opts)
  M.add(opts.line1, opts.line2)
end, { range = true })
cmd("ClaudeReviewed", function(opts)
  M.toggle_reviewed_range(opts.line1, opts.line2)
end, { range = true })
cmd("ClaudeReviewedFile", M.toggle_reviewed_file, {})
cmd("ClaudeReviewedReset", M.reset_reviewed, {})
cmd("ClaudeReviewFinish", M.finish, {})
cmd("ClaudeReviewHistory", M.history, {})
cmd("ClaudeReviewResend", M.resend, {})

local map = vim.keymap.set
map({ "n", "v" }, "<leader>rc", ":ClaudeReviewComment<CR>", { desc = "Review: comment on line", silent = true })
map("n", "<leader>rd", M.remove_at_cursor, { desc = "Review: delete comment here" })
map("n", "<leader>rl", M.list, { desc = "Review: list comments / reviewed" })
map("n", "<leader>rx", M.clear, { desc = "Review: discard all (archived)" })
map("n", "<leader>rs", M.send, { desc = "Review: send to Claude Code" })
map("n", "<leader>rp", M.pick_target, { desc = "Review: pick target Claude pane" })
map("n", "<leader>rh", M.history, { desc = "Review: browse history" })
map("n", "<leader>rR", M.resend, { desc = "Review: re-send a past batch" })
map({ "n", "v" }, "<leader>rv", ":ClaudeReviewed<CR>", { desc = "Review: toggle reviewed (line/range)", silent = true })
map("n", "<leader>rV", M.toggle_reviewed_file, { desc = "Review: toggle reviewed (whole file)" })
map("n", "<leader>rX", M.finish, { desc = "Review: finish (clear comments + reviewed, archived)" })

return M
