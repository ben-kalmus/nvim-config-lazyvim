return {
    "lewis6991/gitsigns.nvim",
    opts = {
        -- max_file_length = 40000, -- Disable if file is longer than this (in lines)
        _threaded_diff = false, -- Fix for "Not in async context" error
        signs_staged_enable = true,
        signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
        watch_gitdir = {
            follow_files = true,
        },
        -- add counter to display num of removed lines
        signs_staged = {
            topdelete = {
                show_count = true,
            },
            delete = {
                show_count = true,
            },
        },
        signs = {
            topdelete = {
                show_count = true,
            },
            delete = {
                show_count = true,
            },
        },
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
            delay = 400,
            ignore_whitespace = false,
            virt_text_priority = 100,
            use_focus = true,
        },
        numhl = true, -- highlights line numbers
    },
}
