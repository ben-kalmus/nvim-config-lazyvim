return {
	"ibhagwan/fzf-lua",
	cmd = "FzfLua",
	keys = {
		-- Quick access
		{ "<leader><leader>", "<cmd>FzfLua files<cr>", desc = "Find Files" },

		-- Search prefix (LazyVim style)
		{ "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "Grep (search)" },
		{ "<leader>sw", "<cmd>FzfLua grep_cword<cr>", desc = "Word (search)" },
		{ "<leader>sW", "<cmd>FzfLua grep_cWORD<cr>", desc = "WORD (search)" },
		{ "<leader>sv", "<cmd>FzfLua grep_visual<cr>", desc = "Visual selection (search)", mode = "v" },
		{ "<leader>sb", "<cmd>FzfLua buffers<cr>", desc = "Buffers (search)" },
		{ "<leader>sh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags (search)" },
		{ "<leader>sr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files (search)" },
		{ "<leader>sc", "<cmd>FzfLua commands<cr>", desc = "Commands (search)" },
		{ "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps (search)" },
		{ "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document symbols (search)" },
		{ "<leader>sS", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Workspace symbols (search)" },

		-- Also keep some <leader>f mappings for compatibility
		{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find Files (FZF)" },
		{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep (FZF)" },
		{ "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent Files (FZF)" },
	},
	opts = function(_, opts)
		local fzf = require("fzf-lua")
		-- local config = fzf.config
		local actions = fzf.actions
		return {
			winopts = {
				height = 0.9,
				width = 0.9,
				preview = {
					layout = "vertical",
					vertical = "down:70%",
				},
			},
			previewers = {
				builtin = {
					syntax_limit_b = 1024 * 100, -- 100KB
					treesitter = {
						enabled = true,
					},
				},
			},
			-- Global keybindings available in all pickers
			keymap = {
				builtin = {
					["<C-/>"] = "toggle-help",
					["<c-f>"] = "preview-page-down",
					["<c-b>"] = "preview-page-up",
				},
				fzf = {
					["ctrl-q"] = "select-all+accept",
					["ctrl-d"] = "half-page-down",
					["ctrl-u"] = "half-page-up",

					["ctrl-f"] = "preview-page-down",
					["ctrl-b"] = "preview-page-up",

					-- Word jumping in search input
					["ctrl-left"] = "backward-word",
					["ctrl-right"] = "forward-word",
					["alt-b"] = "backward-word",
					["alt-f"] = "forward-word",
				},
			},
			files = {
				-- Support for !pattern inverse search
				-- Example: type "!test.go" to exclude test files
				prompt_title = "Files (use ! to exclude)",
				git_icons = true,
				file_icons = true,
				color_icons = true,
				-- Additional useful options
				fd_opts = "--color=auto --type f --hidden --follow --exclude .git",
				actions = {
					-- ["ctrl-g"] = function(selected, opts)
					-- 	require("fzf-lua").live_grep({ query = vim.fn.expand("<cword>") })
					-- end,
					["alt-i"] = { actions.toggle_ignore },
					["alt-h"] = { actions.toggle_hidden },
				},
			},
			grep = {
				prompt_title = "Live Grep (use ! to exclude)",
				-- Supports inverse patterns like "search !test.go"
				-- rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
				-- actions = {
				-- 	["ctrl-f"] = function(selected, opts)
				-- 		require("fzf-lua").files()
				-- 	end,
				-- },
			},
			lsp = {
				-- Exclude declaration from references to avoid duplicates
				includeDeclaration = false,
				-- Jump directly if there's only one result (updated option name)
				jump1 = true,
				-- Ignore current line to avoid showing where cursor is
				ignore_current_line = true,
			},
		}
	end,
}
