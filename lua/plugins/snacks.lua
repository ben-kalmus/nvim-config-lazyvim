return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	-- Disable LazyVim's standalone <leader>gd (Snacks.picker.git_diff) so it
	-- doesn't shadow the local <leader>gd* chord namespace for Diffview
	-- (gdh/gdH/gdm/gdM/gdb/gdd/gdf in lua/config/keymaps.lua).
	keys = {
		{ "<leader>gd", false },
		{
			"<leader>ps",
			function()
				Snacks.profiler.scratch()
			end,
			desc = "Profiler Scratch Buffer",
		},
	},
	opts = function()
		Snacks.toggle.profiler():map("<leader>pp")
		Snacks.toggle.profiler_highlights():map("<leader>ph")

		return {
			profiler = {
				enabled = true,
				filter_fn = { default = true, ["^gitsigns%."] = false },
				filter_mod = { default = true, ["^gitsigns%."] = false },
			},
			win = { backdrop = false },
			styles = { sidebar = { backdrop = false } },
			input = { enabled = true },
			-- Keep previews, but remove work that scales with preview size and result count.
			picker = {
				enabled = true,
				limit = 5000,
				limit_live = 5000,
				matcher = {
					filename_bonus = false,
					file_pos = false,
				},
				icons = {
					files = { enabled = false },
					git = { enabled = false },
				},
				formatters = {
					file = { git_status_hl = false },
				},
				previewers = {
					file = {
						max_size = 256 * 1024,
						max_line_length = 240,
					},
				},
				win = {
					preview = {
						wo = {
							breakindent = false,
							cursorline = false,
							foldenable = false,
							foldexpr = "0",
							foldmethod = "manual",
							list = false,
							number = false,
							relativenumber = false,
							signcolumn = "no",
							spell = false,
							wrap = false,
						},
					},
				},
				sources = {
					buffers = { unloaded = false },
					files = { limit = 5000, limit_live = 5000 },
					grep = { limit = 5000, limit_live = 5000 },
					grep_word = { limit = 5000, limit_live = 5000 },
					explorer = {
						diagnostics = false,
						follow_file = false,
						git_status = false,
						git_untracked = false,
						watch = false,
					},
				},
			},
			-- External image.nvim still handles editor Markdown. Skip Snacks image probing in pickers.
			image = { enabled = false },
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
		}
	end,
}
