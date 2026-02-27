require("nvchad.configs.lspconfig").defaults()

-- Global toggle for format on save (default: enabled)
vim.g.format_on_save = true

-- Toggle format on save command
vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
	vim.g.format_on_save = not vim.g.format_on_save
	local status = vim.g.format_on_save and "enabled" or "disabled"
	vim.notify("Format on save " .. status, vim.log.levels.INFO)
end, { desc = "Toggle format on save" })

-- Helper function to add build flags for gopls
local function add_build_flags()
	local mappings = {
		-- Edit these to configure specific build tags if the project matches the following dir pattern
		-- { pattern = "test", tags = "some_tag" },
	}
	local tag_string = ""
	local cwd = vim.loop.cwd()

	for _, mapping in pairs(mappings) do
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

-- Custom LSP server configurations
local lsp_configs = {
	-- basedpyright handles all Python intelligence: go-to-def, references, hover, completions
	basedpyright = {
		settings = {
			basedpyright = {
				disableOrganizeImports = true, -- ruff handles imports
				analysis = {
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					diagnosticMode = "workspace",
				},
			},
		},
	},
	-- Ruff handles only linting and formatting, not navigation
	ruff = {
		on_attach = function(client)
			-- Disable hover and completions so Pyright handles them
			client.server_capabilities.hoverProvider = false
		end,
	},
	gopls = {
		settings = {
			gopls = vim.tbl_deep_extend("force", add_build_flags(), {
				-- Allow gopls to analyze dependencies
				directoryFilters = {
					"-**/node_modules",
					"+**/pkg/mod", -- Enable Go modules cache
				},
				-- Enable analysis of dependencies
				analyses = {
					unusedparams = true,
					shadow = true,
				},
				staticcheck = true,
				-- Better dependency analysis
				experimentalWorkspaceModule = true,
				allowImplicitNetworkAccess = true,
				-- Deeper analysis
				codelenses = {
					gc_details = false,
					generate = true,
					regenerate_cgo = true,
					test = true,
					tidy = true,
					upgrade_dependency = true,
					vendor = true,
				},
				hints = {
					assignVariableTypes = false,
					compositeLiteralFields = false,
					compositeLiteralTypes = false,
					constantValues = false,
					functionTypeParameters = false,
					parameterNames = false,
					rangeVariableTypes = false,
				},
			}),
		},
	},
	clangd = {
		cmd = {
			vim.fn.stdpath("data") .. "/mason/bin/clangd",
			"--background-index",
			"--clang-tidy",
			"--completion-style=detailed",
			"--header-insertion=never",
			"--compile-commands-dir=build/Debug",
		},
		init_options = {
			clangdFileStatus = true,
		},
	},
}

-- Setup mason-lspconfig to automatically configure all installed servers
require("mason-lspconfig").setup({
	automatic_installation = true,
	handlers = {
		-- Default handler for all servers
		function(server_name)
			local config = lsp_configs[server_name] or {}
			vim.lsp.config(server_name, config)
			vim.lsp.enable(server_name)
		end,
	},
})

-- Setup LSP keybindings with Telescope integration (LazyVim-style)
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)

		-- Enable format on save if LSP supports formatting
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = bufnr,
				callback = function()
					if vim.g.format_on_save then
						vim.lsp.buf.format({ bufnr = bufnr })
					end
				end,
			})
		end

		-- Helper function for buffer-local keymaps
		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "LSP: " .. desc })
		end

		-- LSP Navigation keybindings using FzfLua
		map("n", "gd", "<cmd>FzfLua lsp_definitions<cr>", "Goto Definition")
		map("n", "gr", "<cmd>FzfLua lsp_references<cr>", "Goto References")
		map("n", "gI", "<cmd>FzfLua lsp_implementations<cr>", "Goto Implementation")
		map("n", "gy", "<cmd>FzfLua lsp_typedefs<cr>", "Goto Type Definition")
		map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")

		-- Symbols
		map("n", "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", "Document Symbols")
		map("n", "<leader>sS", "<cmd>FzfLua lsp_workspace_symbols<cr>", "Workspace Symbols")

		-- Code actions (using actions-preview for better UI)
		map({ "n", "v" }, "<leader>ca", function()
			require("actions-preview").code_actions()
		end, "Code Action")
		map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
		map({ "n", "v" }, "<leader>cf", function()
			vim.lsp.buf.format({ bufnr = bufnr })
		end, "Format Buffer")

		-- Documentation
		map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
		map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")

		-- Diagnostics
		map("n", "<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
		map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
		map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
	end,
})

-- Debug and fix LSP hover rendering
vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
	if err or not result or not result.contents then
		return
	end

	config = config or {}
	config.border = "rounded"
	config.focusable = true
	config.stylize_markdown = false -- Disable markdown styling

	-- Use plain text rendering
	local bufnr, winnr = vim.lsp.util.open_floating_preview(
		vim.lsp.util.convert_input_to_markdown_lines(result.contents, {}),
		"markdown",
		config
	)

	if bufnr and winnr then
		-- Force plain text rendering
		vim.bo[bufnr].filetype = ""
		vim.bo[bufnr].syntax = "off"
		vim.wo[winnr].conceallevel = 0
		vim.wo[winnr].concealcursor = ""
		vim.wo[winnr].wrap = true

		-- Completely disable treesitter
		vim.api.nvim_buf_call(bufnr, function()
			pcall(vim.treesitter.stop, bufnr)
		end)
	end

	return bufnr, winnr
end

-- read :h vim.lsp.config for changing options of lsp servers
