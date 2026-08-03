-- Autocmds are automatically loaded by LazyVim.

-- External-edit coexistence (claude-code / opencode write files we have open)
-- ---------------------------------------------------------------------------
-- Goal: when an AI plugin edits a file on disk, pull the change in silently
-- instead of the "W12 / load or overwrite" prompt.
--
-- Two pieces are needed:
--  1. checktime, to notice the on-disk change. FocusGained fires when nvim
--     regains OS focus, but the AI plugins run *inside* nvim (terminal/job) so
--     focus never changes. Add idle (CursorHold) and terminal-exit triggers.
--  2. FileChangedShell handler, to auto-answer the reload/overwrite prompt.
--
-- Trade-off: if you have UNSAVED edits to the same file when the AI writes it,
-- reloading replaces your buffer with the AI's version. We still reload (no
-- prompt, as requested) but emit a warning so it is not a silent data loss.
-- Deliberately NOT on BufEnter/BufWinEnter: that stats the disk on every buffer
-- switch (the I/O the original FocusGained-only comment avoided). CursorHold
-- already catches AI writes while you stay focused, so it is redundant.
vim.api.nvim_create_autocmd({ "FocusGained", "CursorHold", "CursorHoldI", "TermLeave", "TermClose" }, {
	callback = function()
		-- only real file buffers; skip prompts/terminals/special buffers
		if vim.bo.buftype == "" and vim.fn.mode() ~= "c" then
			pcall(vim.cmd.checktime)
		end
	end,
})

vim.api.nvim_create_autocmd("FileChangedShell", {
	callback = function(args)
		-- reason: "changed" (disk changed), "conflict" (also modified in nvim),
		-- "deleted", "renamed". Reload for anything that still exists on disk.
		if vim.v.fcs_reason == "deleted" then
			vim.v.fcs_choice = ""
			return
		end
		if vim.bo[args.buf].modified then
			vim.schedule(function()
				vim.notify(
					"Reloaded " .. vim.fn.fnamemodify(args.file, ":t") .. " from disk; unsaved buffer edits were replaced",
					vim.log.levels.WARN
				)
			end)
		end
		vim.v.fcs_choice = "reload"
	end,
})

-- vim.api.nvim_create_autocmd("WinLeave", {
-- 	callback = function()
-- 		if vim.bo.buftype == "terminal" then
-- 			vim.b.term_insert_mode = vim.fn.mode() == "t"
-- 		end
-- 	end,
-- })

-- vim.api.nvim_create_autocmd("WinEnter", {
-- 	callback = function()
-- 		if vim.bo.buftype == "terminal" and vim.api.nvim_win_get_config(0).relative == "" then
-- 			if vim.b.term_insert_mode ~= false then
-- 				vim.cmd("startinsert")
-- 			end
-- 		end
-- 	end,
-- })

local function set_search_highlights()
	vim.api.nvim_set_hl(0, "Search", { bg = "#2d4a6e", fg = "#c8ccd4" })
	vim.api.nvim_set_hl(0, "IncSearch", { bg = "#61afef", fg = "#1e222a" })
	vim.api.nvim_set_hl(0, "CurSearch", { bg = "#61afef", fg = "#1e222a" })
end

set_search_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = set_search_highlights,
})

local python_lsp_error_only = {
	virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
	signs = { severity = { min = vim.diagnostic.severity.ERROR } },
	underline = { severity = { min = vim.diagnostic.severity.ERROR } },
}

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and (client.name == "basedpyright" or client.name == "ruff") then
			local ok, ns = pcall(vim.lsp.diagnostic.get_namespace, client.id)
			if ok then
				vim.diagnostic.config(python_lsp_error_only, ns)
			end
		end
	end,
})
