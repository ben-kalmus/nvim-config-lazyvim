return {
	"mfussenegger/nvim-dap",
	dependencies = {
		-- Go debugger adapter
		"leoluz/nvim-dap-go",
		-- Debug UI
		{
			"rcarriga/nvim-dap-ui",
			dependencies = { "nvim-neotest/nvim-nio" },
			opts = {},
			config = function(_, opts)
				local dap = require("dap")
				local dapui = require("dapui")
				dapui.setup(opts)
				-- Auto-open UI when debugging starts
				dap.listeners.after.event_initialized["dapui_config"] = function()
					dapui.open({})
				end
				dap.listeners.before.event_terminated["dapui_config"] = function()
					dapui.close({})
				end
				dap.listeners.before.event_exited["dapui_config"] = function()
					dapui.close({})
				end
			end,
			keys = {
				{
					"<leader>du",
					function()
						require("dapui").toggle({})
					end,
					desc = "Toggle DAP UI",
				},
				{
					"<leader>de",
					function()
						require("dapui").eval()
					end,
					desc = "Eval",
					mode = { "n", "v" },
				},
			},
		},
	},
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
	config = function(_, opts)
		-- Setup dap-go after nvim-dap is loaded
		require("dap-go").setup({
			delve = {
				path = "dlv",
				initialize_timeout_sec = 20,
				port = "${port}",
			},
			dap_configurations = {
				{
					type = "go",
					name = "Attach remote",
					mode = "remote",
					request = "attach",
				},
			},
		})
	end,
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
        { "<F4>", function() require("dap").run_to_cursor() end, desc = "Run to Cursor F4" },
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
