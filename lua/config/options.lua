-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--

local opt = vim.opt
-- opt.shiftwidth = 4 -- Size of an indent
opt.tabstop = 4 -- Number of spaces tabs count for
opt.timeoutlen = 50 -- vim.g.vscode and 1000 or 300 --  Lower than default (1000) to quickly trigger which-key
opt.smartindent = true

-- disable auto format on save
vim.g.autoformat = true

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

vim.opt.conceallevel = 1 -- Hide * markup for bold and italic, but not markers with substitutions

-- disable animations like scrolling (prefer snappiness)
vim.g.snacks_animate = false
-- disable blink:
-- vim.g.lazyvim_cmp = "nvim-cmp"
