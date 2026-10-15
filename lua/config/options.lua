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
