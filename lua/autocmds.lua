require("nvchad.autocmds")

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
