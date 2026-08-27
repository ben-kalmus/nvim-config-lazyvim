local opencode_acp_cmd = "env"
local opencode_acp_args = { "-u", "TMUX", "opencode", "acp" }

return {
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false,
		build = "make",
		opts = {
			provider = "claude-code",

			acp_providers = {
				opencode = {
					command = opencode_acp_cmd,
					args = opencode_acp_args,
				},
				-- Uses the local claude CLI's stored subscription credentials
				["claude-code"] = {
					command = "npx",
					-- alternative: @zed-industries/claude-code-acp
					args = { "-y", "@agentclientprotocol/claude-agent-acp" },
					env = {
						-- generate token with `claude setup-token` and place under env
						CLAUDE_CODE_OAUTH_TOKEN = os.getenv("CLAUDE_CODE_OAUTH_TOKEN"),
					},
				},
			},

			providers = {
				openrouter = {
					__inherited_from = "openai",
					endpoint = "https://openrouter.ai/api/v1",
					api_key_name = "OPENROUTER_API_KEY",
					model = "deepseek-v4-flash-latest",
					extra_request_body = {
						temperature = 0.7,
						max_tokens = 32768,
					},
				},
			},

			behaviour = {
				auto_apply_diff_after_generation = false,
				acp_follow_agent_locations = true,
				auto_focus_on_diff_view = true,
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
			{ "<leader>aP", "<cmd>AvanteSwitchProvider<cr>", desc = "Avante: switch provider" },
			{ "<leader>af", "<cmd>AvanteFocus<cr>", desc = "Avante Focus sidebar" },
		},
	},
}
