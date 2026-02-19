-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "onedark",

	hl_override = {
		-- Replace jarring yellow search highlights with muted blue
		Search    = { bg = "#2d4a6e", fg = "#c8ccd4" }, -- dim blue bg, soft text
		IncSearch = { bg = "#61afef", fg = "#1e222a" }, -- bright blue bg, dark text (current match while typing)
		CurSearch = { bg = "#61afef", fg = "#1e222a" }, -- same as IncSearch (focused match)
	},
}

-- M.nvdash = { load_on_startup = true }

M.colorify = {
	enabled = false, -- Disable built-in color highlighting
}

M.ui = {
	statusline = {
		modules = {
			cursor = function()
				local sep_l = require("nvchad.stl.utils").separators.default.left
				return "%#St_pos_sep#" .. sep_l .. "%#St_pos_icon# %#St_pos_text# %l/%v  %p%% "
			end,
		},
	},
}

-- M.ui = {
-- 	tabufline = {
-- 		lazyload = false
-- 	}
-- }

return M
