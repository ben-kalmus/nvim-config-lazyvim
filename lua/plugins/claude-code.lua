return {
	"coder/claudecode.nvim",
	dependencies = {
		"folke/snacks.nvim",
	},
	keys = {
		-- Main Claude Code commands
		{
			"<C-.>",
			"<cmd>ClaudeCode<cr>",
			desc = "Toggle Claude Code",
			mode = { "n", "v", "t", "x" },
		},
		{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
		{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude Code" },
		{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude Code" },
		{ "<leader>aR", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude Code Session" },
		{ "<leader>aV", "<cmd>ClaudeCodeVerbose<cr>", desc = "Claude Code Verbose" },

		-- Model and context management
		{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude Model" },
		{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add Current Buffer to Claude" },
		{
			"<leader>av",
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
		terminal_cmd = "env -u TMUX claude --allow-dangerously-skip-permissions",

		-- Server Configuration
		port_range = { min = 10000, max = 65535 },
		auto_start = true,
		log_level = "warn",

		-- Selection Tracking: re-enabled. The debounce is 100ms and only sends IPC when
		-- the selection actually changes (change detection guard in selection.lua).
		-- The previous freeze was caused by illuminate's LSP provider, not this.
		track_selection = true,

		-- Terminal Configuration
		terminal = {
			provider = "snacks",
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
