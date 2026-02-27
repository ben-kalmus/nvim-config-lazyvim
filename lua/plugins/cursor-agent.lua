return {
	-- "xTacobaco/cursor-agent.nvim", -- original creator
	"waldnzwrld/cursor-agent.nvim",
	branch = "sidebar-instead-of-floating-window",
	cmd = { "CursorAgent", "CursorAgentSelection", "CursorAgentBuffer" },
	keys = {
		-- { "<C-.>", "<cmd>CursorAgent<CR>", desc = "Cursor Agent: Toggle terminal", mode = { "n", "t" } },
		{ "<leader>CC", "<cmd>CursorAgent<CR>", desc = "Cursor Agent: Toggle terminal", mode = "n" },
		{ "<leader>CS", ":<C-u>CursorAgentSelection<CR>", desc = "Cursor Agent: Send selection", mode = "v" },
		{ "<leader>CB", "<cmd>CursorAgentBuffer<CR>", desc = "Cursor Agent: Send buffer", mode = "n" },
	},
	opts = {
		cmd = "cursor-agent", -- Cursor Agent CLI command
		args = {}, -- Additional CLI arguments
		use_stdin = true, -- Send content via stdin
		multi_instance = false, -- Single instance mode
		timeout_ms = 60000, -- 60 second timeout
		auto_scroll = true, -- Auto-scroll terminal
		window_mode = "attached",
		position = "right",
		width = 0.4,
	},
	config = function(_, opts)
		require("cursor-agent").setup(opts)
	end,
}
