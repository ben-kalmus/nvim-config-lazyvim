return {
    "sindrets/diffview.nvim",
    opts = {
        view = {
            merge_tool = {
                layout = "diff3_mixed",
            },
        },
        file_panel = {
            listing_style = "tree", -- One of 'list' or 'tree'
            tree_options = { -- Only applies when listing_style is 'tree'
                flatten_dirs = true, -- Flatten dirs that only contain one single dir
                folder_statuses = "never", -- One of 'never', 'only_folded' or 'always'.
            },
            win_config = { -- See |diffview-config-win_config|
                position = "left",
                width = 35,
                win_opts = {},
            },
        },
    },
}
