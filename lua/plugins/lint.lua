local HOME = vim.fn.expand("~")
return {
	"mfussenegger/nvim-lint",
	optional = true,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- Configure linters by filetype
		-- Go is intentionally omitted: golangci_lint_ls (auto-enabled by
		-- mason-lspconfig) already runs golangci-lint and provides inline
		-- diagnostics. Running both collides on golangci-lint's exclusive
		-- module lock and produces "parallel golangci-lint is running".
		lint.linters_by_ft = {
			markdown = { "markdownlint-cli2" },
		}

		-- Custom linter config
		lint.linters["markdownlint-cli2"].args = {
			"--config",
			HOME .. "/.markdownlint-cli2.yaml",
			"--",
		}

		-- Create autocmd to trigger linting
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		-- Manually trigger linting
        -- this doesnt work
		vim.keymap.set("n", "<leader>cl", function()
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
	-- opts = {
	-- 	linters = {
	-- 		["markdownlint-cli2"] = {
	-- 			-- Disable annoying rule for trailing whitespaces
	-- 			-- args = { "--disable", "MD009", "--" },
	-- 			args = { "--config", HOME .. "/.markdownlint-cli2.yaml", "--" },
	-- 			-- inside .yaml:
	-- 			-- config:
	-- 			--   MD009: false
	-- 		},
	-- 	},
	-- },
}
