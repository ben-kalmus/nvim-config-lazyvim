-- for  more themes: https://dotfyle.com/neovim/colorscheme/trending
return {
    -- custom colorschemes
    { "shaunsingh/nord.nvim" },
    -- schemes: kanagawa-wave [ -wave, -lotus, -dragon ]
    { "EdenEast/nightfox.nvim", opts = {
        transparent = true,
    } },

    -- set colorscheme:
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "nordfox",
        },
    },
}
