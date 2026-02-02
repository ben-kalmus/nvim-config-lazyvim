local add_build_flags = function()
    local mappings = {
        -- Edit these to configure specific build tags if the project matches the following dir pattern
        -- { pattern = "test", tags = "some_tag" },
    }
    local tag_string = ""
    local cwd = vim.loop.cwd() -- current working dir

    for _, mapping in pairs(mappings) do
        -- if current dir matches pattern, append tags to tag_string
        if cwd:match(mapping.pattern) then
            tag_string = tag_string .. mapping.tags .. " "
        end
    end
    if tag_string == "" then
        return {}
    end
    tag_string = "-tags=" .. tag_string

    return {
        buildFlags = { tag_string },
    }
end
return {
    "neovim/nvim-lspconfig",
    opts = {
        server = {
            gopls = {
                settings = {
                    gopls = add_build_flags(),
                },
            },
        },

        -- Disable inlay hints by default
        inlay_hints = { enabled = false },
    },
}
