return {
	-- Prevent LazyVim's base UI spec from installing or configuring Bufferline.
	{ "akinsho/bufferline.nvim", enabled = false },
	{
		"nvim-mini/mini.tabline",
		version = false,
		config = function()
			require("mini.tabline").setup({
				show_icons = true,
				format = function(buf_id, label)
					local modified = vim.bo[buf_id].modified and "+ " or ""
					return MiniTabline.default_format(buf_id, label) .. modified .. "│"
				end,
			})

			local function set_highlights()
				local active = vim.api.nvim_get_hl(0, { name = "TabLineSel", link = false })
				active.bold = true
				vim.api.nvim_set_hl(0, "MiniTablineCurrent", active)
				vim.api.nvim_set_hl(0, "MiniTablineModifiedCurrent", active)
			end

			set_highlights()
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("MiniTablineStyle", { clear = true }),
				callback = set_highlights,
			})
		end,
	},
}
