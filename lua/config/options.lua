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

-- Faster CursorHold (gitsigns, LSP highlights) and shorter wait for mapped sequences
opt.updatetime = 250
opt.timeoutlen = 400

-- Show diagnostic messages at the end of the line (off by default since nvim 0.11)
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  severity_sort = true,
  float = { border = "rounded", source = true },
})

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
