return {
	"folke/persistence.nvim",
	lazy = false,
	opts = {
		dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
		need = 0, -- always save, even if only one buffer
		branch = true,
	},
	config = function(_, opts)
		require("persistence").setup(opts)

		-- Don't let plugin scratch buffers into the session file.
		--
		-- `sessionoptions` contains `buffers`, so :mksession serialises every
		-- listed buffer, including plugin-owned URI buffers like
		-- `diffview://...` and `octo://...`. Those are only meaningful while
		-- their plugin is loaded and holding the matching state. On restore the
		-- plugins are still lazy (diffview is `cmd`-triggered, octo is
		-- `keys`-triggered), so no BufReadCmd handler claims the URI and Neovim
		-- treats it as a literal filename. Two things then go wrong:
		--
		--   1. It creates a swap file for the bogus path. On the next start the
		--      stale swap triggers the E325 ATTENTION prompt in the middle of
		--      session load, which blocks startup.
		--   2. lspconfig attaches gopls to the buffer and sends the non-file
		--      URI, which gopls rejects with `-32700 JSON RPC parse error:
		--      DocumentURI scheme is not 'file'`, killing the client.
		--
		-- Wiping these before the session is written keeps the problem out of
		-- the session file entirely.
		local scratch_schemes = {
			"^diffview://",
			"^octo://",
			"^avante://",
			"^fugitive://",
			"^gitsigns://",
			"^oil://",
			"^https?://",
		}

		local function is_scratch(buf)
			-- Any non-normal buftype (nofile, terminal, prompt, quickfix, help)
			-- has no business being restored from a path.
			if vim.bo[buf].buftype ~= "" then
				return true
			end

			local name = vim.api.nvim_buf_get_name(buf)
			if name == "" then
				return false
			end

			for _, pattern in ipairs(scratch_schemes) do
				if name:match(pattern) then
					return true
				end
			end

			-- Named scratch buffers with no scheme, e.g. neotest's summary
			-- window, which had six stale swap files of its own.
			if name:match("Neotest Summary$") then
				return true
			end

			return false
		end

		vim.api.nvim_create_autocmd("User", {
			pattern = "PersistenceSavePre",
			group = vim.api.nvim_create_augroup("persistence_filter_scratch", { clear = true }),
			callback = function()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_valid(buf) and is_scratch(buf) then
						pcall(vim.api.nvim_buf_delete, buf, { force = true })
					end
				end
			end,
		})
	end,
	init = function()
		-- Auto-restore session for the cwd when Neovim starts with no file args.
		vim.api.nvim_create_autocmd("VimEnter", {
			group = vim.api.nvim_create_augroup("persistence_auto_restore", { clear = true }),
			callback = function()
				if vim.fn.argc() == 0 then
					-- Defer to allow lazy loading to complete and LSP to be ready.
					vim.schedule(function()
						-- Guarded: a single bad line in a session file must not
						-- abort the rest of the VimEnter chain and leave the
						-- editor half-initialised.
						local ok, err = pcall(require("persistence").load)
						if not ok then
							vim.notify(
								"persistence: session restore failed\n" .. tostring(err),
								vim.log.levels.WARN,
								{ title = "persistence.nvim" }
							)
						end
					end)
				end
			end,
		})
	end,
	keys = {
		{
			"<leader>qs",
			function()
				require("persistence").load()
			end,
			desc = "Restore Session",
		},
		{
			"<leader>qS",
			function()
				require("persistence").select()
			end,
			desc = "Select Session",
		},
		{
			"<leader>ql",
			function()
				require("persistence").load({ last = true })
			end,
			desc = "Restore Last Session",
		},
		{
			"<leader>qd",
			function()
				require("persistence").stop()
			end,
			desc = "Don't Save Current Session",
		},
	},
}
