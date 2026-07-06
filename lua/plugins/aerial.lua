return {
	"stevearc/aerial.nvim",
	event = "LspAttach",
	enabled = false,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{ "<leader>O", "<cmd>AerialToggle!<CR>", desc = "Toggle Code Outline (Aerial)" },
		-- Note: Navigate using j/k in the outline window instead of ]o/[o to avoid treesitter conflicts
	},
	opts = {
		backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },
		layout = {
			min_width = 28,
			default_direction = "right",
			placement = "edge",
		},
		attach_mode = "global",
		show_guides = true,
		filter_kind = {
			"Class",
			"Constructor",
			"Enum",
			"Function",
			"Interface",
			"Module",
			"Method",
			"Struct",
			"Type",
			"Variable",
			"Constant",
		},
		guides = {
			mid_item = "├─",
			last_item = "└─",
			nested_top = "│ ",
			whitespace = "  ",
		},
		keymaps = {
			["<CR>"] = "actions.jump",
			["<C-v>"] = "actions.jump_vsplit",
			["<C-s>"] = "actions.jump_split",
			["q"] = "actions.close",
		},
	},
}
