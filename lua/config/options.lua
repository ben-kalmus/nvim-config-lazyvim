-- Options are automatically loaded before lazy.nvim startup.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.lazyvim_picker = "snacks"
vim.g.lazyvim_cmp = "nvim-cmp"

local opt = vim.opt

opt.modeline = false
opt.relativenumber = true
opt.wrap = false

-- Show search count, e.g. "[1/5]".
opt.shortmess:remove("S")

opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true

-- Tree-sitter fold expressions run repeatedly while drawing. Keep folds manual
-- until explicitly created with `zf`.
opt.foldmethod = "manual"
opt.foldexpr = "0"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- Use pbcopy/pbpaste directly with caching to avoid blocking subprocess calls
-- on every register operation (unnamedplus without this spawns pbpaste repeatedly).
vim.g.clipboard = {
	name = "pbcopy",
	copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
	paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
	cache_enabled = true,
}
opt.clipboard = "unnamedplus"

opt.autoread = true
opt.jumpoptions:append("clean")
opt.sessionoptions = "buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds"

opt.listchars = { tab = "· " }
