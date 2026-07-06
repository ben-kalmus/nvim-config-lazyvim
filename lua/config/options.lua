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

-- Cache large-file check per buffer to avoid fs_stat syscall on every fold evaluation.
local _fold_large_file_cache = {}
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  callback = function(ev)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
    _fold_large_file_cache[ev.buf] = ok and stats and stats.size > 1024 * 1024
  end,
})
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(ev)
    _fold_large_file_cache[ev.buf] = nil
  end,
})

function _G.FoldExpr()
  local bufnr = vim.api.nvim_get_current_buf()
  if _fold_large_file_cache[bufnr] then
    return "0"
  end
  return vim.treesitter.foldexpr()
end

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.FoldExpr()"
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
