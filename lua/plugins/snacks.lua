-- Minimal snacks.nvim setup
-- Opencode-specific snacks config is in opencode.lua
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		-- Enable features we want
		input = { enabled = true },
		picker = { enabled = true },
		terminal = { enabled = true },
		notifier = {
			enabled = true,
			timeout = 3000, -- Default timeout in ms
		},

		-- Explicitly disable everything else to avoid conflicts with NvChad
		bigfile = { enabled = false },
		dashboard = { enabled = false },
		explorer = { enabled = false },
		indent = { enabled = false },
		quickfile = { enabled = false },
		scope = { enabled = false },
		scroll = { enabled = false },
		statuscolumn = { enabled = false },
		words = { enabled = false },
	},
}
