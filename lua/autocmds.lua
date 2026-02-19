require("nvchad.autocmds")

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
