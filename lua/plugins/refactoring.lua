return {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    event = "VeryLazy",
    keys = {
        -- Extract (visual mode)
        { "<leader>re", function() require("refactoring").refactor("Extract Function") end, mode = "x", desc = "Extract Function" },
        { "<leader>rf", function() require("refactoring").refactor("Extract Function To File") end, mode = "x", desc = "Extract Function To File" },
        { "<leader>rv", function() require("refactoring").refactor("Extract Variable") end, mode = "x", desc = "Extract Variable" },

        -- Inline (normal/visual)
        { "<leader>ri", function() require("refactoring").refactor("Inline Variable") end, mode = { "n", "x" }, desc = "Inline Variable" },

        -- Extract block (normal mode)
        { "<leader>rb", function() require("refactoring").refactor("Extract Block") end, desc = "Extract Block" },
        { "<leader>rB", function() require("refactoring").refactor("Extract Block To File") end, desc = "Extract Block To File" },

        -- Show refactoring menu
        { "<leader>rr", function() require("refactoring").select_refactor() end, mode = { "n", "x" }, desc = "Select Refactor" },
    },
    opts = {
        prompt_func_return_type = {
            go = true,
        },
        prompt_func_param_type = {
            go = true,
        },
    },
}
