return {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
        require("lazy").load({ plugins = { "markdown-preview.nvim" } })
        vim.fn["mkdp#util#install"]()
    end,
    keys = {
        {
            "<leader>cp",
            ft = "markdown",
            "<cmd>MarkdownPreviewToggle<cr>",
            desc = "Markdown Preview",
        },
    },
    config = function()
        vim.g.mkdp_auto_close = 0
        -- vim.g.mkdp_port = '8080'
        vim.g.mkdp_theme = 'dark'

        -- vim.cmd([[do FileType]])
    end,
}
