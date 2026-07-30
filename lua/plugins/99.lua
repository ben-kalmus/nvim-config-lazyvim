return {
	"ThePrimeagen/99",
	dependencies = {
		"ibhagwan/fzf-lua", -- for model/provider selection
		"saghen/blink.compat",
	},
	keys = {
		{
			"<leader>0a",
			function()
				require("99").visual()
			end,
			desc = "99: Send visual selection",
			mode = { "n", "v" },
		},
		{
			"<leader>0x",
			function()
				require("99").stop_all_requests()
			end,
			desc = "99: Stop all requests",
		},
		{
			"<leader>0s",
			function()
				require("99").search()
			end,
			desc = "99: Search",
		},
		{
			"<leader>0m",
			function()
				require("99.extensions.fzf_lua").select_model()
			end,
			desc = "99: Select model",
		},
		-- Keybinding: <leader>ap opens a provider selection menu via fzf-lua
		-- Allows switching between different AI providers (e.g., Claude, OpenAI)
		{
			"<leader>0p",
			function()
				require("99.extensions.fzf_lua").select_provider()
			end,
			desc = "99: Select provider",
		},
	},
	-- Configuration function for the 99 plugin
	-- Sets up AI provider, completion source, context files, and logging
	config = function()
		local _99 = require("99")

		-- Get the current working directory to create project-specific log files
		local cwd = vim.uv.cwd()
		-- Extract the directory name (e.g., "nvim-config" from "/Users/user/nvim-config")
		local basename = vim.fs.basename(cwd)
		_99.setup({

			provider = _99.Providers.ClaudeCodeProvider,
			completion = { source = "blink" },
			md_files = { "CLAUDE.md" },
			tmp_dir = "./tmp/99/",
			logger = {
				level = _99.DEBUG,
				type = "file",
				path = "/tmp/99/" .. basename .. ".99.debug",
				print_on_error = true,
			},
		})
	end,
}
