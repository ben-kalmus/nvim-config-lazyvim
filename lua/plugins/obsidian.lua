return {
    "epwalsh/obsidian.nvim",
    enabled = false, -- !!!DISABLED!!!

    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    -- event = {
    --     "BufReadPre " .. vim.fn.expand "~" .. "/notes-vault/personal/*.md",
    --     "BufNewFile " .. vim.fn.expand "~" .. "/notes-vault/personal/*.md",
    -- },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "hrsh7th/nvim-cmp",
        "nvim-telescope/telescope.nvim",
    },
    opts = {
        ui = {
            -- enable = false,
            enable = true,
        },
        workspaces = {
            {
                name = "Notes",
                path = "~/notes-vault/personal",
            },
        },
        daily_notes = {
            folder = "dailies", -- keep daily notes in a separate folder
            template = "templates/daily.md",
        },
        templates = {
            subdir = "templates",
        },
    },
}
