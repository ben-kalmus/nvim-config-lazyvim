return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	-- Disable LazyVim's standalone <leader>gd (Snacks.picker.git_diff) so it
	-- doesn't shadow the local <leader>gd* chord namespace for Diffview
	-- (gdh/gdH/gdm/gdM/gdb/gdd/gdf in lua/config/keymaps.lua).
	keys = {
		{ "<leader>gd", false },
	},
	opts = {
		input = { enabled = true },
		picker = { enabled = true },
		explorer = { enabled = true },
		terminal = {
			enabled = true,
			win = {
				wo = {
					-- Prevent treesitter foldexpr from running on terminal buffers.
					-- With foldmethod=expr globally, nvim evaluates folds on every line
					-- of terminal output, which is slow and serves no purpose in a terminal.
					foldmethod = "manual",
					foldexpr = "0",
				},
			},
		},
		notifier = {
			enabled = true,
			timeout = 3000,
			refresh = 200,
		},
		scroll = { enabled = false },
		indent = { enabled = false },
		dashboard = { enabled = false },
		words = { enabled = true },
		bigfile = {
			line_length = 100000,
			setup = function(ctx)
				if vim.fn.exists(":NoMatchParen") ~= 0 then
					vim.cmd("NoMatchParen")
				end
				Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
				vim.b.completion = false
				vim.b.minianimate_disable = true
				vim.b.minihipatterns_disable = true
				vim.schedule(function()
					if vim.api.nvim_buf_is_valid(ctx.buf) then
						vim.bo[ctx.buf].syntax = ctx.ft
					end
				end)
				for _, client in pairs(vim.lsp.get_clients({ bufnr = ctx.buf })) do
					vim.lsp.buf_detach_client(ctx.buf, client.id)
				end
				pcall(vim.treesitter.stop, ctx.buf)
			end,
		},
	},
}
