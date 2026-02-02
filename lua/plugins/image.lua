return {
    "3rd/image.nvim",
    enabled = false,
    build = false,
    config = function()
        require("image").setup({
            backend = "wezterm",
            integrations = { markdown = { enabled = true } },
        })
    end,
}
