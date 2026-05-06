return {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
        -- Directory where session files are saved
        dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
        -- sessionoptions used for saving
        options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" },
        -- enable saving sessions on VimLeavePre
        pre_save = nil,
        -- disable saving the session by default, only save on explicit command
        -- set to false to save on every VimLeavePre
        save_empty = false,
    },
    -- Auto-restore session for the cwd when Neovim starts with no file args.
    init = function()
        vim.api.nvim_create_autocmd("VimEnter", {
            group = vim.api.nvim_create_augroup("persistence_auto_restore", { clear = true }),
            nested = true,
            callback = function()
                -- Only restore if nvim was opened without file arguments.
                if vim.fn.argc() == 0 then
                    require("persistence").load()
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
