return {
	"uga-rosa/ccc.nvim",
	enabled = true, -- NvChad has built-in color highlighting
	event = "VeryLazy",
	config = function()
		local ccc = require("ccc")
		ccc.setup({
			highlighter = {
				auto_enable = false, -- Manual toggle only: <leader>mh
				lsp = false,
			},
			-- Available pickers
			pickers = {
				ccc.picker.hex, -- Hex color picker
				ccc.picker.css_rgb, -- RGB picker
				ccc.picker.css_hsl, -- HSL picker
				ccc.picker.css_hwb, -- HWB picker
				ccc.picker.css_lab, -- LAB picker
				ccc.picker.css_lch, -- LCH picker
				ccc.picker.css_oklab, -- OKLAB picker
				ccc.picker.css_oklch, -- OKLCH picker
			},
			-- Output formats when inserting colors
			outputs = {
				ccc.output.hex, -- #RRGGBB
				ccc.output.hex_short, -- #RGB (if possible)
				ccc.output.css_rgb, -- rgb(R, G, B)
				ccc.output.css_hsl, -- hsl(H, S%, L%)
			},
			alpha_show = "auto", -- Show alpha slider when color has alpha
		})
	end,
	keys = {
		{ "<leader>mc", "<cmd>CccPick<cr>", desc = "Color Picker" },
		{ "<leader>mC", "<cmd>CccConvert<cr>", desc = "Color Convert" },
		{ "<leader>mh", "<cmd>CccHighlighterToggle<cr>", desc = "Color Highlight Toggle" },
	},
}
