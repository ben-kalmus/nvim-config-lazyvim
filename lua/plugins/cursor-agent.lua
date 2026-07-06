return {
	-- "xTacobaco/cursor-agent.nvim", -- original creator
	"waldnzwrld/cursor-agent.nvim",
	-- enabled = false,
	-- branch = "sidebar-instead-of-floating-window",
	cmd = { "CursorAgent", "CursorAgentSelection", "CursorAgentBuffer" },
	keys = {
		{ "<C-;>", "<cmd>CursorAgent<CR>", desc = "Cursor Agent: Toggle terminal", mode = { "n", "t" } },
		{ "<leader>CC", "<cmd>CursorAgent<CR>", desc = "Cursor Agent: Toggle terminal", mode = { "n", "t" } },
		{
			"<leader>CS",
			":<C-u>CursorAgentSelection<CR>",
			desc = "Cursor Agent: Send selection",
			mode = { "n", "t" },
		},
		{ "<leader>CB", "<cmd>CursorAgentBuffer<CR>", desc = "Cursor Agent: Send buffer", mode = { "n", "t" } },
	},
	opts = {
		cmd = "cursor-agent", -- Cursor Agent CLI command
		args = {}, -- Additional CLI arguments
		use_stdin = false, -- Send content via stdin
		multi_instance = true, -- Single instance mode
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
