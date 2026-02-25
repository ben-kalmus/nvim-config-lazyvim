return {
	"greggh/claude-code.nvim",
	enabled = false, -- Disabled in favor of opencode.nvim
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	keys = {
		-- { "<C-,>", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code", mode = { "n", "t" } },
		-- { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
		{ "<leader>aC", "<cmd>ClaudeCodeContinue<cr>", desc = "Continue Claude Code" },
		{ "<leader>aR", "<cmd>ClaudeCodeResume<cr>", desc = "Resume Claude Code Session" },
		{ "<leader>aV", "<cmd>ClaudeCodeVerbose<cr>", desc = "Claude Code Verbose" },
		-- {
		-- 	"<leader>as",
		-- 	"<cmd>ClaudeCodeSend<cr>",
		-- 	mode = "v",
		-- 	desc = "Claude send Selection",
		-- },
	},
	opts = {
		window = {
			split_ratio = 0.4, -- Terminal takes 40% of screen
			position = "vertical", -- Bottom right split
			enter_insert = true, -- Auto-enter insert mode

			-- Alternative: Use floating window (uncomment if preferred)
			-- position = "float",
			-- float = {
			--   width = "85%",
			--   height = "85%",
			--   row = "center",
			--   col = "center",
			--   border = "rounded",
			-- },
		},
		refresh = {
			enable = true, -- Auto-reload modified files
			updatetime = 100, -- Check interval (ms)
		},
		git = {
			use_git_root = true, -- Use git root as working directory
		},
		keymaps = {
			toggle = {
				normal = "<C-,>", -- Normal mode toggle
				terminal = "<C-,>", -- Terminal mode toggle
				variants = {
					continue = "<leader>cC", -- Resume last conversation
					verbose = "<leader>cV", -- Enable verbose output
				},
			},
		},
	},
	config = function(_, opts)
		require("claude-code").setup(opts)
	end,
}
