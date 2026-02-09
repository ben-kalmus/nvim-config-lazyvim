return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	event = "VeryLazy",
	config = function()
		-- Setup textobjects
		require("nvim-treesitter-textobjects").setup({
			move = {
				enable = true,
				set_jumps = true,
			},
			select = {
				enable = true,
				lookahead = true,
			},
			swap = {
				enable = true,
			},
		})

		-- Define movement keymaps
		local moves = {
			goto_next_start = {
				["]f"] = "@function.outer",
				["]s"] = "@class.outer",
				["]a"] = "@parameter.inner",
				["]l"] = "@loop.outer", -- loops (for/while)
				["]i"] = "@conditional.outer", -- if/switch statements
				["]m"] = "@call.outer", -- method/function calls
				["]z"] = "@fold", -- folds
			},
			goto_next_end = {
				["]F"] = "@function.outer",
				["]S"] = "@class.outer",
				["]A"] = "@parameter.inner",
				["]L"] = "@loop.outer",
				["]I"] = "@conditional.outer",
				["]M"] = "@call.outer",
			},
			goto_previous_start = {
				["[f"] = "@function.outer",
				["[s"] = "@class.outer",
				["[a"] = "@parameter.inner",
				["[l"] = "@loop.outer",
				["[i"] = "@conditional.outer",
				["[m"] = "@call.outer",
				["[z"] = "@fold",
			},
			goto_previous_end = {
				["[F"] = "@function.outer",
				["[S"] = "@class.outer",
				["[A"] = "@parameter.inner",
				["[L"] = "@loop.outer",
				["[I"] = "@conditional.outer",
				["[M"] = "@call.outer",
			},
		}

		-- Define select keymaps
		local selects = {
			-- Functions and classes
			["af"] = "@function.outer",
			["if"] = "@function.inner",

			["as"] = "@class.outer",
			["is"] = "@class.inner",

			-- Parameters and arguments
			["aa"] = "@parameter.outer",
			["ia"] = "@parameter.inner",

			-- Conditionals (if/switch)
			["ai"] = "@conditional.outer",
			["ii"] = "@conditional.inner",

			-- Loops (for/while)
			["al"] = "@loop.outer",
			["il"] = "@loop.inner",

			-- Blocks
			["ab"] = "@block.outer",
			["ib"] = "@block.inner",

			-- Calls (function/method calls)
			["am"] = "@call.outer",
			["im"] = "@call.inner",

			-- Comments
			["a/"] = "@comment.outer",
		}

		-- Peek definition in floating window
		local function peek_definition()
			local params = vim.lsp.util.make_position_params()
			return vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result)
				if not result or vim.tbl_isempty(result) then
					vim.notify("No definition found", vim.log.levels.INFO)
					return
				end
				-- Handle both Location and LocationLink
				local location = result[1]
				local uri = location.uri or location.targetUri
				local range = location.range or location.targetSelectionRange

				-- Open in floating window
				vim.lsp.util.preview_location(location, { border = "rounded", max_height = 20 })
			end)
		end

		-- Jump to next/previous LSP symbol (function, class, etc.)
		local function goto_lsp_symbol(direction, symbol_kind)
			local params = { textDocument = vim.lsp.util.make_text_document_params() }
			vim.lsp.buf_request(0, "textDocument/documentSymbol", params, function(_, result)
				if not result or vim.tbl_isempty(result) then
					return
				end

				local symbols = {}
				local function flatten(items, parent_range)
					for _, item in ipairs(items) do
						if not symbol_kind or item.kind == symbol_kind then
							table.insert(symbols, {
								name = item.name,
								kind = item.kind,
								range = item.range or item.location.range,
							})
						end
						if item.children then
							flatten(item.children, item.range)
						end
					end
				end
				flatten(result)

				-- Sort by position
				table.sort(symbols, function(a, b)
					return a.range.start.line < b.range.start.line
				end)

				-- Find current position
				local cursor = vim.api.nvim_win_get_cursor(0)
				local current_line = cursor[1] - 1

				-- Find next/previous symbol
				local target
				if direction == "next" then
					for _, sym in ipairs(symbols) do
						if sym.range.start.line > current_line then
							target = sym
							break
						end
					end
				else
					for i = #symbols, 1, -1 do
						if symbols[i].range.start.line < current_line then
							target = symbols[i]
							break
						end
					end
				end

				if target then
					vim.api.nvim_win_set_cursor(0, { target.range.start.line + 1, target.range.start.character })
					vim.cmd("normal! zz")
				end
			end)
		end

		-- Function to attach keymaps to buffer
		local function attach(buf)
			-- Create movement keymaps
			for method, keymaps in pairs(moves) do
				for key, query in pairs(keymaps) do
					local desc = key:sub(1, 1) == "]" and "Next" or "Prev"
					desc = desc .. " " .. query:gsub("@", ""):gsub("%..*", "")
					vim.keymap.set({ "n", "x", "o" }, key, function()
						require("nvim-treesitter-textobjects.move")[method](query)
					end, { buffer = buf, desc = desc, silent = true })
				end
			end

			-- Create select keymaps
			for key, query in pairs(selects) do
				vim.keymap.set({ "x", "o" }, key, function()
					require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
				end, { buffer = buf, desc = "Select " .. query, silent = true })
			end

			-- Create swap keymaps
			vim.keymap.set("n", "<leader>a", function()
				require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
			end, { buffer = buf, desc = "Swap next parameter", silent = true })

			vim.keymap.set("n", "<leader>A", function()
				require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
			end, { buffer = buf, desc = "Swap previous parameter", silent = true })

			-- Peek definition
			vim.keymap.set("n", "gp", peek_definition, { buffer = buf, desc = "Peek definition", silent = true })

			-- LSP symbol navigation (alternative to treesitter)
			vim.keymap.set("n", "]F", function()
				goto_lsp_symbol("next")
			end, { buffer = buf, desc = "Next LSP symbol", silent = true })

			vim.keymap.set("n", "[F", function()
				goto_lsp_symbol("prev")
			end, { buffer = buf, desc = "Previous LSP symbol", silent = true })

			-- Select entire buffer
			vim.keymap.set(
				{ "x", "o" },
				"ig",
				":<C-u>normal! ggVG<CR>",
				{ buffer = buf, desc = "Select entire buffer", silent = true }
			)
			vim.keymap.set(
				{ "x", "o" },
				"ag",
				":<C-u>normal! ggVG<CR>",
				{ buffer = buf, desc = "Select entire buffer", silent = true }
			)
		end

		-- Attach to all FileType events
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter_textobjects_keymaps", { clear = true }),
			callback = function(ev)
				attach(ev.buf)
			end,
		})

		-- Attach to existing buffers
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(buf) then
				attach(buf)
			end
		end
	end,
}
