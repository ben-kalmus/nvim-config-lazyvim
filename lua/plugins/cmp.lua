return {
    "hrsh7th/nvim-cmp",
    enabled = true,
    opts = function(_, opts)
        local cmp = require("cmp")

        -- Disable cmp in terminal buffers (e.g. claudecode) to prevent
        -- cmp-buffer indexing large terminal output on every keystroke.
        vim.api.nvim_create_autocmd("BufEnter", {
            callback = function()
                if vim.bo.buftype == "terminal" then
                    cmp.setup.buffer({ enabled = false })
                end
            end,
        })

        return vim.tbl_deep_extend("force", opts or {}, {
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
            -- ["<tab>"] = cmp.mapping.confirm({ select = true }),
            ["<C-y>"] = cmp.mapping.confirm({ select = true }),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            -- Allow <Enter Key> to fallthrough
            -- ["<CR>"] = function(fallback)
            --     cmp.abort()
            --     fallback()
            -- end,

            -- ["<C-CR>"] = LazyVim.cmp.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            -- ["<C-CR>"] = function(fallback)
            --     cmp.abort()
            --     fallback()
            -- end,
            -- ["<tab>"] = function(fallback)
            --     return LazyVim.cmp.map({ "snippet_forward", "ai_accept" }, fallback)()
            -- end,
        }),
        -- sources = cmp.config.sources({
        --     { name = "lazydev", group_index = 0 },
        --     { name = "nvim_lsp" },
        --     { name = "path" },
        --     { name = "copilot" },
        --     { name = "buffer" },
        --     { name = "luasnip" },
        -- }),
        -- formatting = {
        --     format = function(entry, vim_item)
        --         -- Add source name to the completion item
        --         vim_item.menu = ({
        --             nvim_lsp = "[LSP]",
        --             path = "[Path]",
        --             copilot = "[AI]",
        --             buffer = "[Buf]",
        --             luasnip = "[Snip]",
        --             lazydev = "[Dev]",
        --         })[entry.source.name]
        --         return vim_item
        --     end,
        -- },
        -- sorting = {
        --     priority_weight = 2,
        --     comparators = {
        --         -- require("copilot_cmp.comparators").prioritize,
        --         cmp.config.compare.offset,
        --         cmp.config.compare.exact,
        --         cmp.config.compare.score,
        --         cmp.config.compare.recently_used,
        --         cmp.config.compare.locality,
        --         cmp.config.compare.kind,
        --         cmp.config.compare.sort_text,
        --         cmp.config.compare.length,
        --         cmp.config.compare.order,
        --     },
        -- },
        })
    end,
}
