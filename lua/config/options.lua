local opt = vim.opt

-- Line numbers (absolute, like VSCode)
opt.number = true
opt.signcolumn = "yes" -- reserve space so gitsigns/diagnostics don't shift the text

-- Tabs / indent: 4 spaces
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.smartindent = true

-- Share the system clipboard (wl-clipboard on Wayland)
opt.clipboard = "unnamedplus"

opt.termguicolors = true
opt.mouse = "a"

-- New splits open to the right / below
opt.splitright = true
opt.splitbelow = true

-- Case-insensitive search unless the pattern has uppercase
opt.ignorecase = true
opt.smartcase = true

-- <leader>t toggles a terminal in a split at the bottom; the shell keeps running while hidden
local term_buf
vim.keymap.set("n", "<leader>t", function()
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    local win = vim.fn.bufwinid(term_buf)
    if win ~= -1 then
      vim.api.nvim_win_hide(win)
      return
    end
    vim.cmd("botright 15split")
    vim.api.nvim_win_set_buf(0, term_buf)
  else
    vim.cmd("botright 15split")
    vim.cmd(vim.fn.has("win32") == 1 and "terminal powershell.exe -NoLogo" or "terminal")
    term_buf = vim.api.nvim_get_current_buf()
  end
  vim.cmd("startinsert")
end, { desc = "Toggle terminal" })
-- Esc leaves terminal mode (use C-w h/j/k/l afterwards to move between windows)
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Faster CursorHold (gitsigns, LSP highlights) and shorter wait for mapped sequences
opt.updatetime = 250
opt.timeoutlen = 400

-- Diagnostics: on the cursor line, every message in full, wrapped below the line (virtual_lines);
-- on the other lines, only the underline and a dot at the end (no text). `gl` opens all of the line's messages in a
-- float, and jumping with ]d / [d opens it too.
-- Virtual lines never wrap on their own (they get cut at the window edge), but they do break on
-- newlines: so wrap each message to the room left to the right of where the diagnostic starts.
local function wrap_diagnostic(diagnostic)
  local text = (diagnostic.source and ("[" .. diagnostic.source .. "] ") or "") .. diagnostic.message
  local gutter = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].textoff
  local width = math.max(30, vim.api.nvim_win_get_width(0) - gutter - diagnostic.col - 6)
  local lines = {}
  for paragraph in text:gmatch("[^\n]+") do
    local line = ""
    for word in paragraph:gmatch("%S+") do
      if line ~= "" and #line + 1 + #word > width then
        table.insert(lines, line)
        line = word
      else
        line = line == "" and word or (line .. " " .. word)
      end
    end
    table.insert(lines, line)
  end
  return table.concat(lines, "\n")
end

vim.diagnostic.config({
  -- off the cursor line: underline + the dot, no text (the message shows when the cursor gets there)
  virtual_text = { current_line = false, spacing = 2, prefix = "●", format = function() return "" end },
  virtual_lines = { current_line = true, format = wrap_diagnostic },
  severity_sort = true,
  float = { border = "rounded", source = true },
  jump = { float = true },
})
vim.keymap.set("n", "gl", function() vim.diagnostic.open_float({ scope = "line" }) end,
  { desc = "Line diagnostics" })

-- Move line/selection up and down, re-indenting it (Alt+j/k, or Alt+arrows like VSCode)
local map = vim.keymap.set
for _, k in ipairs({ { "<A-j>", "<A-k>" }, { "<A-Down>", "<A-Up>" } }) do
  local down, up = k[1], k[2]
  map("n", down, "<cmd>m .+1<cr>==", { desc = "Move line down" })
  map("n", up, "<cmd>m .-2<cr>==", { desc = "Move line up" })
  map("i", down, "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
  map("i", up, "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
  map("v", down, ":m '>+1<cr>gv=gv", { desc = "Move selection down", silent = true })
  map("v", up, ":m '<-2<cr>gv=gv", { desc = "Move selection up", silent = true })
end

-- Autosave: write real file buffers when leaving insert mode, after normal-mode edits,
-- and when switching buffer/window or losing focus. `update` only writes if modified.
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "BufLeave", "FocusLost" }, {
  group = vim.api.nvim_create_augroup("autosave", { clear = true }),
  callback = function(ev)
    local bo = vim.bo[ev.buf]
    if bo.buftype == "" and bo.modifiable and not bo.readonly and vim.api.nvim_buf_get_name(ev.buf) ~= "" then
      vim.api.nvim_buf_call(ev.buf, function() vim.cmd("silent! update") end)
    end
  end,
})

-- Auto-reload files changed on disk (Claude, cargo fmt, git checkout...). `autoread` alone
-- only reacts when nvim happens to check, so trigger the check on focus/buffer/idle events.
opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermLeave" }, {
  group = vim.api.nvim_create_augroup("autoreload", { clear = true }),
  callback = function()
    if vim.fn.getcmdwintype() == "" then vim.cmd("checktime") end
  end,
})
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = "autoreload",
  callback = function() vim.notify("File changed on disk, buffer reloaded", vim.log.levels.INFO) end,
})
