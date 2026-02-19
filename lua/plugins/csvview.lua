return {
	"hat0uma/csvview.nvim",
	enabled = false,
	ft = { "csv", "tsv" },
	opts = {
		parser = {
			delimiter = {
				ft = {
					csv = ",",
					tsv = "\t",
				},
				fallbacks = { ",", "\t", ";", "|" },
			},
			quote_char = '"',
			max_lookahead = 50,
		},
		view = {
			display_mode = "highlight", -- "highlight" or "border" (│ separators)
			min_column_width = 1, -- tight columns, sized to content
			spacing = 1,
			header_lnum = true, -- auto-detect header row
			sticky_header = {
				enabled = true,
				separator = "─",
			},
		},
		keymaps = {
			jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
			jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
			jump_next_row = { "<Enter>", mode = { "n", "v" } },
			jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
			textobject_field_inner = { "if", mode = { "o", "x" } },
			textobject_field_outer = { "af", mode = { "o", "x" } },
		},
	},
	config = function(_, opts)
		require("csvview").setup(opts)

		-- Auto-enable when opening csv/tsv files
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "csv", "tsv" },
			callback = function()
				require("csvview").enable()
			end,
		})
	end,
}
