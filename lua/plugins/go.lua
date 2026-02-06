return {
    "ray-x/go.nvim",
    dependencies = {
        "ray-x/guihua.lua",
        "neovim/nvim-lspconfig",
        "nvim-treesitter/nvim-treesitter",
    },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
    keys = {
        -- Using <leader>G (capital G) - 2 letters only
        { "<leader>Gf", "<cmd>GoFillStruct<CR>", desc = "Go: Fill Struct", ft = "go" },
        { "<leader>Ge", "<cmd>GoIfErr<CR>", desc = "Go: If Err", ft = "go" },
        { "<leader>Ga", "<cmd>GoAddTag<CR>", desc = "Go: Add Tags", ft = "go" },
        { "<leader>Gr", "<cmd>GoRmTag<CR>", desc = "Go: Remove Tags", ft = "go" },
        { "<leader>Gi", "<cmd>GoImpl<CR>", desc = "Go: Implement Interface", ft = "go" },
        { "<leader>Gt", "<cmd>GoTestFunc<CR>", desc = "Go: Test Function", ft = "go" },
        { "<leader>GT", "<cmd>GoTestFile<CR>", desc = "Go: Test File", ft = "go" },
        { "<leader>Gp", "<cmd>GoTestPkg<CR>", desc = "Go: Test Package", ft = "go" },
        { "<leader>Gc", "<cmd>GoCoverage<CR>", desc = "Go: Coverage", ft = "go" },
        { "<leader>Gd", "<cmd>GoCmt<CR>", desc = "Go: Doc Comment", ft = "go" },
    },
    opts = {
        lsp_cfg = false, -- Don't override lspconfig
        lsp_gofumpt = true,
        lsp_on_attach = false, -- Use your existing LSP attach
        diagnostic = false, -- Use your existing diagnostic config
        lsp_keymaps = false, -- Use your existing keymaps
        dap_debug = true,
        dap_debug_gui = true,
        trouble = true,
        luasnip = true,
    },
}
