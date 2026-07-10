return {
	"emmanueltouzery/decisive.nvim",
	ft = { "csv" },
	config = function()
		require("decisive").setup({
			auto_realign_limit_ms = 100,
			auto_realign = { "InsertLeave", "TextChanged" },
		})

		-- Alternating column highlights for easier reading
		vim.api.nvim_set_hl(0, "CsvFillHlEven", { bg = "#2a2a3a" })
		vim.api.nvim_set_hl(0, "CsvFillHlOdd", { bg = "#1e1e2e" })

		-- Auto-align when opening csv files
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "csv",
			callback = function()
				require("decisive").align_csv({})
			end,
		})
	end,
	keys = {
		{
			"<leader>ca",
			function()
				require("decisive").align_csv({})
			end,
			desc = "CSV Align",
			ft = "csv",
		},
		{
			"<leader>cA",
			function()
				require("decisive").align_csv_clear({})
			end,
			desc = "CSV Clear Align",
			ft = "csv",
		},
		{
			"[c",
			function()
				require("decisive").align_csv_prev_col()
			end,
			desc = "CSV Prev Column",
			ft = "csv",
		},
		{
			"]c",
			function()
				require("decisive").align_csv_next_col()
			end,
			desc = "CSV Next Column",
			ft = "csv",
		},
	},
}
