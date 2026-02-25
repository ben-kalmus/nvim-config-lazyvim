return {
	"coder/claudecode.nvim",
	dependencies = {
		"folke/snacks.nvim",
	},
	keys = {
		-- Main Claude Code commands
		{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
		{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude Code" },
		{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude Code" },
		{ "<leader>aR", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude Code Session" },
		{ "<leader>aV", "<cmd>ClaudeCodeVerbose<cr>", desc = "Claude Code Verbose" },

		-- Model and context management
		{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude Model" },
		{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add Current Buffer to Claude" },
		{
			"<leader>aS",
			"<cmd>ClaudeCodeSend<cr>",
			mode = "v",
			desc = "Send Selection to Claude",
		},

		-- Tree file additions (capital T for Claude)
		{
			"<leader>aT",
			"<cmd>ClaudeCodeTreeAdd<cr>",
			desc = "Add File from Tree to Claude",
			ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
		},

		-- Diff management (capital A and D to avoid opencode conflicts)
		{ "<leader>aA", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude Diff" },
		{ "<leader>aD", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny Claude Diff" },
	},
	opts = {
		-- Server Configuration
		port_range = { min = 10000, max = 65535 },
		auto_start = true,
		log_level = "info",

		-- Selection Tracking
		track_selection = true,
		visual_demotion_delay_ms = 50,

		-- Terminal Configuration
		terminal = {
			split_side = "right",
			split_width_percentage = 0.40,
			provider = "snacks",
			auto_close = true,
		},

		-- Git integration - use git root as working directory
		git_repo_cwd = true,

		-- Diff Integration
		diff_opts = {
			auto_close_on_accept = true,
			vertical_split = true,
			open_in_current_tab = true,
			keep_terminal_focus = false,
		},
	},
	config = true,
}
