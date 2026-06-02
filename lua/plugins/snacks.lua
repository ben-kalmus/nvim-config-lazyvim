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
		terminal = { enabled = true },
		notifier = {
			enabled = true,
			timeout = 3000,
		},
		scroll = { enabled = false },
		dashboard = { enabled = false },
		bigfile = {
			line_length = 100000,
			-- Extend Snacks defaults with LSP detach, treesitter stop, and illuminate
			-- pause. Snacks' built-in setup only handles matchparen / completion /
			-- mini-* / fold options, which leaves the actual freeze sources (LSP
			-- indexing, treesitter parse on edit, illuminate word scan) running.
			setup = function(ctx)
				-- snacks defaults (mirrored from snacks/bigfile.lua)
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

				-- additions
				for _, client in pairs(vim.lsp.get_clients({ bufnr = ctx.buf })) do
					vim.lsp.buf_detach_client(ctx.buf, client.id)
				end
				pcall(vim.treesitter.stop, ctx.buf)
				pcall(function()
					require("illuminate.engine").stop_buf(ctx.buf)
				end)
			end,
		},
	},
}
