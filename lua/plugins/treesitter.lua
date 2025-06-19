return {
    "nvim-treesitter/nvim-treesitter",
    opts = {
        textobjects = {
            swap = {
                enable = true,
                swap_next = {
                    ["<leader>ck"] = "@parameter.inner",
                },
                swap_previous = {
                    ["<leader>cj"] = "@parameter.inner",
                },
            },
        },
    },
}
