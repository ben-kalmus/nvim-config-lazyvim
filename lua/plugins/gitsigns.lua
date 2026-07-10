return {
	"lewis6991/gitsigns.nvim",
	keys = {
		{
			"<leader>gB",
			function()
				local gs = require("gitsigns")
				local buf = vim.api.nvim_get_current_buf()
				local current = vim.b[buf].gitsigns_base
				if current == "HEAD~1" then
					gs.change_base(nil)
					vim.notify("gitsigns: base → index", vim.log.levels.INFO)
				else
					gs.change_base("HEAD~1")
					vim.notify("gitsigns: base → HEAD~1 (last commit)", vim.log.levels.INFO)
				end
			end,
			desc = "Toggle gitsigns base (index ↔ last commit)",
		},
	},
	opts = {
		-- max_file_length = 40000, -- Disable if file is longer than this (in lines)
		_threaded_diff = true, -- Fix for "Not in async context" error
		signs_staged_enable = true,
		signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
		watch_gitdir = {
			follow_files = true,
			interval = 5000,
		},
		-- add counter to display num of removed lines
		signs_staged = {
			topdelete = {
				show_count = true,
			},
			delete = {
				show_count = true,
			},
		},
		signs = {
			topdelete = {
				show_count = true,
			},
			delete = {
				show_count = true,
			},
		},
		current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
			delay = 400,
			ignore_whitespace = false,
			virt_text_priority = 100,
			use_focus = true,
		},
		numhl = true, -- highlights line numbers
	},
}
