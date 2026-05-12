return {
    "folke/persistence.nvim",
    lazy = false,
    opts = {
        dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
        need = 0, -- always save, even if only one buffer
        branch = true,
    },
    init = function()
        -- Auto-restore session for the cwd when Neovim starts with no file args.
        vim.api.nvim_create_autocmd("VimEnter", {
            group = vim.api.nvim_create_augroup("persistence_auto_restore", { clear = true }),
            callback = function()
                if vim.fn.argc() == 0 then
                    -- Defer to allow lazy loading to complete and LSP to be ready.
                    vim.schedule(function()
                        require("persistence").load()
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
