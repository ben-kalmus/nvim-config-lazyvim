return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
        ensure_installed = {
            "lua",
            "vim",
            "vimdoc",
            "python",
            "go",
            "javascript",
            "typescript",
            "tsx",
            "html",
            "css",
            "json",
            "yaml",
            "bash",
            "markdown",
            "markdown_inline",
        },
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
        indent = {
            enable = true,
        },
    },
}
