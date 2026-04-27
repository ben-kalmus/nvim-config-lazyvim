return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		input = { enabled = true },
		picker = { enabled = true },
		explorer = { enabled = true },
		terminal = { enabled = true },
		notifier = {
			enabled = true,
			timeout = 3000,
		},
		scroll = { enabled = false },
	},
}
