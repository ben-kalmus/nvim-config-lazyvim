return {
    "mfussenegger/nvim-dap",
    opts = {
        defaults = {
            fallback = {
                external_terminal = {
                    command = "/usr/bin/zsh",
                    -- args = { "-e" },
                },
            },
        },
    },
    -- stylua: ignore
    keys = {
        { "<leader>d", "", desc = "+debug", mode = {"n", "v"} },
        { "<leader>dD", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
        { "<leader>dd", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },

        { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
        { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },

        { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
        { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
        { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },

        { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },

        { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
        { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
        { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },

        -- adding F keys alternative
        -- vim.keymap.set({"n", "v" }, "<F1>", function() require("dap").step_into() end, {desc = "Step Into F1" })
        { "<F1>", function() require("dap").step_into() end, desc = "Step Into F1" },

        { "<F2>", function() require("dap").step_over() end, desc = "Step Over F2" },
        { "<F3>", function() require("dap").step_out() end, desc = "Step Out F3" },
        -- { "<F4>", function() require("dap").pause() end, desc = "Pause" },
        { "<F5>", function() require("dap").continue() end, desc = "Run/Continue F5" },
        { "<F6>", function() require("dap").pause() end, desc = "Pause F6" },

        { "<leader>dj", function() require("dap").down() end, desc = "Down" },
        { "<leader>dk", function() require("dap").up() end, desc = "Up" },

        { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
        { "<leader>ds", function() require("dap").session() end, desc = "Session" },
        { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
        { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },

        { "<leader>dL", ":DapShowLog<CR>", desc = "Dap Show Log" },
    },
}
