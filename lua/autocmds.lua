require("nvchad.autocmds")

-- Remember and restore terminal mode state per buffer
vim.api.nvim_create_autocmd("WinLeave", {
	callback = function()
		if vim.bo.buftype == "terminal" then
			vim.b.term_insert_mode = vim.fn.mode() == "t"
		end
	end,
})

vim.api.nvim_create_autocmd("WinEnter", {
	callback = function()
		if vim.bo.buftype == "terminal" and vim.api.nvim_win_get_config(0).relative == "" then
			-- Default to terminal mode on first visit (vim.b.term_insert_mode is nil)
			if vim.b.term_insert_mode ~= false then
				vim.cmd("startinsert")
			end
		end
	end,
})

-- Override jarring yellow search highlights with muted blue
local function set_search_highlights()
	vim.api.nvim_set_hl(0, "Search",    { bg = "#2d4a6e", fg = "#c8ccd4" })
	vim.api.nvim_set_hl(0, "IncSearch", { bg = "#61afef", fg = "#1e222a" })
	vim.api.nvim_set_hl(0, "CurSearch", { bg = "#61afef", fg = "#1e222a" })
end

set_search_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = set_search_highlights,
})

-- Only show errors for Python LSPs (basedpyright + ruff), not warnings
local python_lsp_error_only = {
	virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
	signs = { severity = { min = vim.diagnostic.severity.ERROR } },
	underline = { severity = { min = vim.diagnostic.severity.ERROR } },
}

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and (client.name == "basedpyright" or client.name == "ruff") then
			local ns = vim.lsp.diagnostic.get_namespace(client.id)
			vim.diagnostic.config(python_lsp_error_only, ns)
		end
	end,
})

-- Auto-restore session on startup
vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("restore_session", { clear = true }),
	callback = function()
		-- Only load the session if nvim was started with no arguments
		if vim.fn.argc(-1) == 0 then
			require("persistence").load()
		end
	end,
	nested = true,
})
