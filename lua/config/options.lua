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

function _G.FoldExpr()
  local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
  if ok and stats and stats.size > 1024 * 1024 then
    return "0"
  end
  return vim.treesitter.foldexpr()
end

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.FoldExpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

opt.autoread = true
opt.jumpoptions:append("clean")
