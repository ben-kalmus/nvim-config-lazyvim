return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {
		highlight = {
			backdrop = false,
			matches = true,
		},
	},
	config = function(_, opts)
		require("flash").setup(opts)

		-- Override highlight groups after flash loads
		vim.api.nvim_set_hl(0, "FlashMatch", { bg = "#2d4a6e", fg = "#c8ccd4" }) -- all matches: muted blue
		vim.api.nvim_set_hl(0, "FlashCurrent", { bg = "#61afef", fg = "#1e222a" }) -- current match: bright blue
		vim.api.nvim_set_hl(0, "FlashLabel", { bg = "#c678dd", fg = "#1e222a", bold = true }) -- jump labels: purple
	end,
	keys = {
		{
			"s",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash",
		},
		{
			"S",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter",
		},
		{
			"r",
			mode = "o",
			function()
				require("flash").remote()
			end,
			desc = "Remote Flash",
		},
		{
			"R",
			mode = { "o", "x" },
			function()
				require("flash").treesitter_search()
			end,
			desc = "Treesitter Search",
		},
		{
			"<c-s>",
			mode = { "c" },
			function()
				require("flash").toggle()
			end,
			desc = "Toggle Flash Search",
		},
	},
}
