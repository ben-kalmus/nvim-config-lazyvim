return {
	-- Label the <leader>o prefix in which-key.
	{
		"folke/which-key.nvim",
		opts = {
			spec = {
				{ "<leader>o", group = "octo" },
			},
		},
	},
	-- Move octo's global maps off the crowded <leader>g prefix onto <leader>o.
	-- The util.octo extra puts them under <leader>g{i,I,p,P,r,S}, which collides
	-- with gitsigns/diffview/lazygit/worktrees (e.g. <leader>gp is also Gitsigns
	-- preview hunk). Disable the extra's <leader>g octo maps and rehome under
	-- <leader>o (+octo), adding <leader>on for notifications (the extra had none).
	{
		"pwntester/octo.nvim",
		keys = {
			-- disable the extra's <leader>g octo maps
			{ "<leader>gi", false },
			{ "<leader>gI", false },
			{ "<leader>gp", false },
			{ "<leader>gP", false },
			{ "<leader>gr", false },
			{ "<leader>gS", false },
			-- rehome under <leader>o
			{ "<leader>op", "<cmd>Octo pr list<CR>", desc = "List PRs (Octo)" },
			{ "<leader>oP", "<cmd>Octo pr search<CR>", desc = "Search PRs (Octo)" },
			{ "<leader>oi", "<cmd>Octo issue list<CR>", desc = "List Issues (Octo)" },
			{ "<leader>oI", "<cmd>Octo issue search<CR>", desc = "Search Issues (Octo)" },
			{ "<leader>on", "<cmd>Octo notification list<CR>", desc = "Notifications (Octo)" },
			{ "<leader>oc", "<cmd>Octo pr checkout<CR>", desc = "Checkout PR (Octo)" },
			{ "<leader>or", "<cmd>Octo repo list<CR>", desc = "List Repos (Octo)" },
			{ "<leader>os", "<cmd>Octo search<CR>", desc = "Search (Octo)" },
			{ "<leader>oR", "<cmd>Octo pr reload<CR>", desc = "Reload PR (Octo)" },
			-- Review-style diff layout WITHOUT starting a review (no "started
			-- reviewing" posted to GitHub; only populates existing threads).
			{ "<leader>ob", "<cmd>Octo review browse<CR>", desc = "Browse PR diff, no review (Octo)" },
			-- Review: list pending review comments (jump back to a collapsed comment).
			-- localleader (\) keeps it with octo's other review maps (\vs, \vd...).
			-- `Octo review comments` self-guards outside a review, so a global map is safe.
			{ "<localleader>vc", "<cmd>Octo review comments<CR>", desc = "Review pending comments (Octo)" },
			{ "<leader>ot", "<cmd>Octo review thread<CR>", desc = "Show comment thread at cursor (Octo)" },
		},
		opts = function(_, opts)
			-- Use the real on-disk file for the RIGHT side of reviews instead of the
			-- octo:// virtual buffer. Gives full native LSP (hover/gd/gr/diagnostics)
			-- and avoids gopls choking on octo:// URIs ("go: chdir octo://...").
			-- Requires the PR branch checked out (`Octo pr checkout`) so the working
			-- tree matches the PR head.
			opts.use_local_fs = true

			-- Sort `Octo pr list` by most-recently-updated instead of created.
			opts.pull_requests = vim.tbl_deep_extend("force", opts.pull_requests or {}, {
				order_by = { field = "UPDATED_AT", direction = "DESC" },
			})

			-- Don't pop comment threads open just from cursor movement (jarring).
			-- Open them on demand with <leader>ot (Octo review thread).
			opts.reviews = vim.tbl_deep_extend("force", opts.reviews or {}, {
				auto_show_threads = false,
			})

			-- When a PR buffer is actually opened (e.g. selected via <leader>op),
			-- offer to check it out locally. use_local_fs reviews read the working
			-- tree, so a checkout is what makes the RIGHT side match the PR head.
			-- Kept optional so previewing a PR never switches your branch (or risks
			-- your uncommitted changes) without consent.
			--
			-- Use BufEnter (not FileType): the snacks picker loads the PR into an
			-- octo buffer to PREVIEW it on hover, which fires FileType octo. BufEnter
			-- only fires when the buffer becomes the focused window (i.e. on select),
			-- and we additionally require the current, non-floating window to be it.
			-- octo populates the buffer async with no ready event, so poll for the
			-- PR node, then prompt once.
			vim.api.nvim_create_autocmd("BufEnter", {
				group = vim.api.nvim_create_augroup("octo_checkout_prompt", { clear = true }),
				callback = function(args)
					local buf = args.buf
					if vim.bo[buf].filetype ~= "octo" or vim.b[buf].octo_checkout_prompted then
						return
					end
					local win = vim.api.nvim_get_current_win()
					-- must be the focused buffer in a normal (non-preview/float) window
					if vim.api.nvim_win_get_buf(win) ~= buf then
						return
					end
					if vim.api.nvim_win_get_config(win).relative ~= "" then
						return
					end
					-- Guard: only one poll loop per buffer at a time. Without this, each
					-- BufEnter (e.g. every window switch back to the buffer) spawns a
					-- fresh loop with its own tries counter. They accumulate and fire
					-- concurrently, causing nlua_schedule_event to pile up and the
					-- bufnr() pattern matcher to thrash against the full buffer list,
					-- pegging a CPU core indefinitely.
					if vim.b[buf].octo_checkout_polling then
						return
					end
					vim.b[buf].octo_checkout_polling = true

					local tries = 0
					local function poll()
						tries = tries + 1
						local ob = _G.octo_buffers and _G.octo_buffers[buf]
						if ob and ob:isPullRequest() and ob.node and ob.node.number then
							vim.b[buf].octo_checkout_prompted = true
							vim.b[buf].octo_checkout_polling = false
							-- skip if already on the PR head branch
							local head = ob.node.headRefName
							local cur = vim.fn.systemlist({ "git", "branch", "--show-current" })[1]
							if head and cur and head == cur then
								return
							end
							vim.ui.select({ "Yes", "No" }, {
								prompt = "Checkout PR #" .. ob.node.number .. " locally?",
							}, function(choice)
								if choice == "Yes" then
									require("octo.utils").checkout_pr(ob.node.number)
								end
							end)
						elseif tries < 40 then
							vim.defer_fn(poll, 150)
						else
							-- Poll exhausted without finding the PR node. Clear the flag so
							-- a subsequent BufEnter can retry (e.g. octo finished loading late).
							vim.b[buf].octo_checkout_polling = false
						end
					end
					vim.defer_fn(poll, 150)
				end,
			})

			-- Local patches for octo bugs (notification picker crash on CI
			-- notifications, "Invalid buffer id" on picker-preview scroll). Kept in
			-- their own file to keep this config readable; see it for details.
			require("configs.octo_fixes").install()

			return opts
		end,
	},
}
