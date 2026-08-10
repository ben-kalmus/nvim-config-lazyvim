local opencode_acp_cmd = "env"
local opencode_acp_args = { "-u", "TMUX", "opencode", "acp" }

return {
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		-- version = false,
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
				auto_apply_diff_after_generation = false,
				acp_follow_agent_locations = true,
			},

			windows = {
				width = 35,
				sidebar_header = {
					enabled = true,
					align = "center",
					rounded = true,
				},
				ask = {
					floating = true,
					start_insert = true,
				},
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-mini/mini.icons",
			{
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
		keys = {
			{ "<C-'>", "<cmd>AvanteToggle<cr>", desc = "Avante Toggle sidebar", mode = { "n", "v", "i" } },
			{ "<leader>at", "<cmd>AvanteToggle<cr>", desc = "Avante Toggle sidebar", mode = { "n", "v", "i" } },
			{ "<leader>ae", "<cmd>AvanteEdit<cr>", desc = "Avante Edit selection", mode = { "n", "v" } },
			{ "<leader>aa", "<cmd>AvanteAsk<cr>", desc = "Avante Ask (floating)", mode = { "n", "v" } },
			{ "<leader>as", "<cmd>AvanteStop<cr>", desc = "Avante Stop" },
			{ "<leader>ah", "<cmd>AvanteHistory<cr>", desc = "Avante History" },
			{ "<leader>af", "<cmd>AvanteFocus<cr>", desc = "Avante Focus sidebar" },
		},
	},
}
