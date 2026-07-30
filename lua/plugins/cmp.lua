return {
	"saghen/blink.cmp",
	opts = {
		completion = {
			list = {
				selection = {
					preselect = false,
					auto_insert = true,
				},
			},
		},
		keymap = {
			preset = "enter",
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
			["<C-n>"] = { "select_next", "fallback_to_mappings" },
			["<C-p>"] = { "select_prev", "fallback_to_mappings" },
			["<C-y>"] = { "select_and_accept", "fallback" },
			["<CR>"] = { "select_and_accept", "fallback" },
		},
	},
}
