return {
    "lewis6991/gitsigns.nvim",
    opts = {
        max_file_length = 40000, -- Disable if file is longer than this (in lines)

        signs = {
            delete = { show_count = true },
            topdelete = { show_count = true },
        },
        signs_staged = {
            delete = { show_count = true },
            topdelete = { show_count = true },
        },
        signs_staged_enable = true,
        signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
        numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
        watch_gitdir = {
            follow_files = true,
        },
        current_line_blame = true,
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
            delay = 500,
            ignore_whitespace = false,
            virt_text_priority = 100,
            use_focus = true,
        },
    },
}
