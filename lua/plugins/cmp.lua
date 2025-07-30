local cmp = require("cmp")
return {
    "hrsh7th/nvim-cmp",
    enabled = true,
    opts = {
        completion = {
            completeopt = "menu,menuone,noselect,noinsert,popup",
        },
        preselect = cmp.PreselectMode.None,
        mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
            ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
            -- C-Space is already a tmux keybind
            -- ["<C-Space>"] = cmp.mapping.complete(),
            ["<tab>"] = LazyVim.cmp.confirm({ select = true }),
            ["<C-y>"] = LazyVim.cmp.confirm({ select = true }),
            -- Allow <Enter Key> to fallthrough
            ["<CR>"] = function(fallback)
                cmp.abort()
                fallback()
            end,

            -- ["<C-CR>"] = LazyVim.cmp.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            -- ["<C-CR>"] = function(fallback)
            --     cmp.abort()
            --     fallback()
            -- end,
            -- ["<tab>"] = function(fallback)
            --     return LazyVim.cmp.map({ "snippet_forward", "ai_accept" }, fallback)()
            -- end,
        }),
    },
}
