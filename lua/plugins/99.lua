-- additional_prompt:
-- If provided, skips the interactive prompt buffer entirely and sends the string directly as the prompt. If omitted, you get the normal prompt capture window where you type your prompt (with @file / #rule completions).
-- With additional_prompt — no prompt buffer, sends instantly
-- _99.visual({ additional_prompt = "add error handling to this function" })
-- Without — opens the prompt buffer for you to type
-- _99.visual()
-- additional_rules: Injects Rule objects (name + path to a markdown file) into the AI context. The rule content gets appended to the system prompt. Works the same way #rule completions work in the prompt buffer, but done programmatically.
-- _99.visual({
-- additional_rules = {
-- { name = "lua-style", path = "./rules/lua-style.md" },
-- },
-- additional_prompt = "refactor this to be more idiomatic",
--

return {
	"ThePrimeagen/99",
	dependencies = {
		"ibhagwan/fzf-lua", -- for model/provider selection
		"saghen/blink.compat",
	},
	keys = {
		{
			"<leader>00",
			function()
				require("99").visual()
			end,
			desc = "99: Send visual selection",
			mode = { "v" },
		},
		{
			"<leader>0o",
			function()
				require("99").open()
			end,
			desc = "99: Open interaction window",
		},
		{
			"<leader>0l",
			function()
				require("99").view_logs()
			end,
			desc = "99: View logs",
		},
		{
			"<leader>0c",
			function()
				require("99").clear_previous_requests()
			end,
			desc = "99: Wipes history!!",
		},
		{
			"<leader>0i",
			function()
				require("99").info()
			end,
			desc = "99: Show request info and rules",
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

			provider = _99.Providers.OpenCodeProvider,
			completion = { source = "blink" },
			md_files = {
				"AGENTS.md",
				"AGENT.md",
			},
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
