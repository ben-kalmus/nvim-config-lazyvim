require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

local opt = vim.opt
opt.relativenumber = true

-- Tab settings (4 spaces)
opt.tabstop = 4        -- Number of spaces a tab counts for
opt.shiftwidth = 4     -- Size of an indent
opt.softtabstop = 4    -- Number of spaces tab key inserts
opt.expandtab = true   -- Use spaces instead of tabs
-- opt.timeoutlen = 50 -- vim.g.vscode and 1000 or 300 --  Lower than default (1000) to quickly trigger which-key
-- opt.smartindent = true
--
-- -- Set completeopt to have a better completion experience
-- vim.o.completeopt = "menuone,noselect"
--
-- vim.opt.conceallevel = 1 -- Hide * markup for bold and italic, but not markers with substitutions
--
-- -- disable animations like scrolling (prefer snappiness)
-- vim.g.snacks_animate = false
