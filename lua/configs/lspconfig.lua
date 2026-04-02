require("nvchad.configs.lspconfig").defaults()

-- Global toggle for format on save (default: enabled)
vim.g.format_on_save = true

-- Toggle format on save command
vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
	vim.g.format_on_save = not vim.g.format_on_save
	local status = vim.g.format_on_save and "enabled" or "disabled"
	vim.notify("Format on save " .. status, vim.log.levels.INFO)
end, { desc = "Toggle format on save" })

-- Known GOOS values (not custom build tags)
local known_goos = {
	aix = true,
	android = true,
	darwin = true,
	dragonfly = true,
	freebsd = true,
	illumos = true,
	ios = true,
	js = true,
	linux = true,
	netbsd = true,
	openbsd = true,
	plan9 = true,
	solaris = true,
	wasip1 = true,
	wasip2 = true,
	windows = true,
	zos = true,
}

-- Known GOARCH values (not custom build tags)
local known_goarch = {
	["386"] = true,
	amd64 = true,
	arm = true,
	arm64 = true,
	loong64 = true,
	mips = true,
	mips64 = true,
	mips64le = true,
	mipsle = true,
	ppc64 = true,
	ppc64le = true,
	riscv64 = true,
	s390x = true,
	wasm = true,
}

-- Tags to always exclude from detection
local excluded_tags = {
	ignore = true,
	cgo = true,
}

--- Check if a tag identifier is a custom build tag (not a platform/arch/version)
--- @param tag string
--- @return boolean
local function is_custom_tag(tag)
	if known_goos[tag] or known_goarch[tag] or excluded_tags[tag] then
		return false
	end
	-- Filter Go version constraints like go1.21
	if tag:match("^go%d") then
		return false
	end
	return true
end

--- Extract custom build tags from lines of a Go file header
--- @param lines string[]
--- @return table<string, boolean> set of custom tag names
local function extract_tags_from_lines(lines)
	local tags = {}
	for _, line in ipairs(lines) do
		-- Stop at package clause (nothing after this is a build directive)
		if line:match("^package%s+") then
			break
		end
		-- New syntax: //go:build <expression>
		local expr = line:match("^//go:build%s+(.+)$")
		if expr then
			for tag in expr:gmatch("[%w_]+") do
				if is_custom_tag(tag) then
					tags[tag] = true
				end
			end
		end
		-- Old syntax: // +build <tags>
		local build_expr = line:match("^//%s+%+build%s+(.+)$")
		if build_expr then
			for tag in build_expr:gmatch("[%w_]+") do
				if is_custom_tag(tag) then
					tags[tag] = true
				end
			end
		end
	end
	return tags
end

--- Scan all Go files in the workspace for custom build tags.
--- Uses git ls-files for speed in git repos, falls back to vim.fn.glob.
--- @return string[] sorted list of unique custom build tag names
local function scan_go_build_tags()
	local files = {}
	local cwd = vim.uv.cwd() or vim.loop.cwd()

	-- Try git ls-files first (fast, respects .gitignore)
	local git_result = vim.fn.systemlist("git ls-files '*.go' 2>/dev/null")
	if vim.v.shell_error == 0 and #git_result > 0 then
		files = git_result
	else
		-- Fallback: recursive glob (slower in large repos)
		local glob_results = vim.fn.glob(cwd .. "/**/*.go", false, true)
		for _, f in ipairs(glob_results) do
			-- Make paths relative for consistency
			files[#files + 1] = f:sub(#cwd + 2)
		end
	end

	local all_tags = {}

	for _, rel_path in ipairs(files) do
		local abs_path = cwd .. "/" .. rel_path
		-- Read only the first 20 lines (build tags must appear before the package clause)
		local ok, lines = pcall(function()
			local f = io.open(abs_path, "r")
			if not f then
				return {}
			end
			local result = {}
			for i = 1, 20 do
				local line = f:read("*l")
				if not line then
					break
				end
				result[i] = line
			end
			f:close()
			return result
		end)

		if ok and lines and #lines > 0 then
			local file_tags = extract_tags_from_lines(lines)
			for tag in pairs(file_tags) do
				all_tags[tag] = true
			end
		end
	end

	-- Return sorted list
	local result = vim.tbl_keys(all_tags)
	table.sort(result)
	return result
end

--- Apply build tags to all running gopls clients dynamically (no restart needed).
--- @param tags string[] list of tag names to enable
local function apply_gopls_build_tags(tags)
	if #tags == 0 then
		return
	end

	local flag = "-tags=" .. table.concat(tags, ",")
	local clients = vim.lsp.get_clients({ name = "gopls" })

	for _, client in ipairs(clients) do
		client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
			gopls = {
				buildFlags = { flag },
			},
		})
		-- Notify gopls that config changed. gopls will pull new settings
		-- via workspace/configuration request.
		client:notify("workspace/didChangeConfiguration", {
			settings = client.settings,
		})
	end
end

-- Track whether we've already scanned for this session to avoid repeat scans
-- on every buffer attach.
local gopls_tags_applied = false

--- Scan the workspace for Go build tags and apply them to gopls.
--- @param opts? { force?: boolean, silent?: boolean }
local function refresh_gopls_tags(opts)
	opts = opts or {}
	if gopls_tags_applied and not opts.force then
		return
	end

	local tags = scan_go_build_tags()
	gopls_tags_applied = true

	if #tags > 0 then
		apply_gopls_build_tags(tags)
		if not opts.silent then
			vim.notify("gopls: auto-detected build tags: " .. table.concat(tags, ", "), vim.log.levels.INFO)
		end
	end
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
			gopls = {
				-- Build tags are auto-detected and applied dynamically on LspAttach.
				-- Use :GoplsRefreshTags to re-scan, :GoplsBuildTags to view active tags.

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
			},
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

-- User commands for gopls build tag management
vim.api.nvim_create_user_command("GoplsRefreshTags", function()
	refresh_gopls_tags({ force = true })
end, { desc = "Re-scan workspace for Go build tags and apply to gopls" })

vim.api.nvim_create_user_command("GoplsBuildTags", function()
	local clients = vim.lsp.get_clients({ name = "gopls" })
	if #clients == 0 then
		vim.notify("gopls is not running", vim.log.levels.WARN)
		return
	end
	for _, client in ipairs(clients) do
		local flags = (client.settings.gopls or {}).buildFlags or {}
		if #flags == 0 then
			vim.notify("gopls: no build tags active", vim.log.levels.INFO)
		else
			vim.notify("gopls build flags: " .. table.concat(flags, " "), vim.log.levels.INFO)
		end
	end
end, { desc = "Show currently active gopls build tags" })

local function is_large_file(bufnr)
	local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
	return ok and stats and stats.size > 1024 * 1024 -- 1MB
end

-- Setup LSP keybindings with Telescope integration (LazyVim-style)
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)

		-- Skip LSP features entirely for large files
		if is_large_file(bufnr) then
			vim.lsp.buf_detach_client(bufnr, args.data.client_id)
			return
		end

		-- Auto-detect and apply build tags when gopls attaches
		if client and client.name == "gopls" then
			-- Schedule to run after gopls is fully initialized
			vim.schedule(function()
				refresh_gopls_tags()
			end)
		end

		-- Enable format on save if LSP supports formatting
		if client:supports_method("textDocument/formatting") then
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

		-- Illuminate reference navigation (buffer-local to override ftplugin's ]] / [[)
		vim.keymap.set("n", "]]", function()
			require("illuminate").goto_next_reference()
		end, { buffer = bufnr, desc = "Next Reference" })
		vim.keymap.set("n", "[[", function()
			require("illuminate").goto_prev_reference()
		end, { buffer = bufnr, desc = "Prev Reference" })
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
