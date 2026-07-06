-- Autocmds are automatically loaded by LazyVim.

-- checktime on FocusGained only. BufEnter causes a disk check on every buffer
-- switch which adds I/O on large repos with many open buffers.
vim.api.nvim_create_autocmd("FocusGained", {
    command = "checktime",
})

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
            if vim.b.term_insert_mode ~= false then
                vim.cmd("startinsert")
            end
        end
    end,
})

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

