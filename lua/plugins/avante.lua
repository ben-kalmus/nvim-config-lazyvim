local opencode_acp_cmd = "env"
local opencode_acp_args = { "-u", "TMUX", "opencode", "acp" }

return {
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false,
		-- unused for now
		enabled = false,
		build = "make",
		opts = {
			provider = "opencode",

			acp_providers = {
				opencode = {
					command = opencode_acp_cmd,
					args = opencode_acp_args,
				},
			},

			behaviour = {
				-- Watch the agent jump to / edit files as it works.
				acp_follow_agent_locations = true,
			},

			-- Optional: nicer defaults
			windows = {
				width = 35,
				sidebar_header = {
					enabled = true,
					align = "center",
					rounded = true,
				},
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",

			-- Icons: LazyVim usually already has mini.icons or nvim-web-devicons.
			"nvim-mini/mini.icons",

			-- Optional but recommended for Avante markdown rendering.
			{
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
		keys = {
			{ "<C-'>", "<cmd>AvanteToggle<cr>", desc = "Avante Toggle", mode = { "n", "v", "i" } },
			{ "<leader>AA", "<cmd>AvanteAsk<cr>", desc = "Avante Ask", mode = { "n", "v" } },
			{ "<leader>AE", "<cmd>AvanteEdit<cr>", desc = "Avante Edit", mode = { "n", "v" } },
			{ "<leader>AR", "<cmd>AvanteRefresh<cr>", desc = "Avante Refresh" },
			{ "<leader>AF", "<cmd>AvanteFocus<cr>", desc = "Avante Focus" },
		},
	},
}
