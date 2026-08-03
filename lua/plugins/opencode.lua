local opencode_cmd = "env -u TMUX opencode --auto --port"
-- local opencode_cmd = "env -u TMUX opencode --port"

local snacks_terminal_opts = {
	win = {
		position = "right",
		enter = false,
	},
}

return {
	"nickjvandyke/opencode.nvim",
	event = "VeryLazy",
	version = "*", -- Latest stable release
	dependencies = {
		{
			-- `snacks.nvim` integration is recommended, but optional
			---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
			"folke/snacks.nvim",
			optional = true,
			opts = {
				input = {}, -- Enhances `ask()`
				picker = { -- Enhances `select()`
					actions = {
						opencode_send = function(picker)
							local items = vim.tbl_map(function(item)
								return item.file
										and require("opencode").format({
											path = item.file,
											from = item.pos,
											to = item.end_pos,
										})
									or item.text
							end, picker:selected({ fallback = true }))

							require("opencode").prompt(table.concat(items, ", ") .. " ")
						end,
					},
					win = {
						input = {
							keys = {
								["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
							},
						},
					},
				},
				terminal = {}, -- Enables the `snacks` provider
			},
		},
	},
	config = function()
		---@type opencode.Opts
		vim.g.opencode_opts = {

			server = {
				start = function()
					require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts)
				end,
				stop = function()
					require("snacks.terminal").get(opencode_cmd, snacks_terminal_opts):close()
				end,
				toggle = function()
					require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
				end,
			},
			events = {
				permissions = {
					enabled = false,
				},
			},
			lsp = {
				enabled = true,
			},
		}

		vim.o.autoread = true -- Required for `opts.events.reload`

		-- Translator proxy: rewrite prompts through a cheap LLM before they reach opencode.
		require("opencode.translator").setup({
			enabled = true, -- toggle live with <leader>at
			mode = "confirm", -- review/edit each translation while tuning the system prompt
			provider = {
				model = "meta-llama/llama-3.1-8b-instruct",
				api_key = vim.env.OPENROUTER_API_KEY,
			},
		})
		require("opencode.translator.patch").apply()

		-- Recommended/example keymaps
		vim.keymap.set({ "n", "x" }, "<leader>aa", function()
			local composer = require("opencode.translator.composer")
			if composer.is_open() then
				composer.focus()
			else
				composer.open():catch(function(err)
					-- err may be nil (user closed without sending) or "cancelled"
					-- (superseded by a newer open()) — both are normal outcomes.
					if err and err ~= "cancelled" then
						vim.notify(tostring(err), vim.log.levels.ERROR, { title = "opencode translator" })
					end
				end)
			end
		end, { desc = "Compose prompt in side window" })

		-- Shared operatorfunc for <leader>ap / <leader>ao: appends the motion /
		-- selection range as an "@this" ref to the open composer buffer.
		local function composer_ref_operator()
			_G.opencode_composer_ref_operator = function(kind)
				local from = vim.api.nvim_buf_get_mark(0, "[")
				local to = vim.api.nvim_buf_get_mark(0, "]")
				if from[1] > to[1] or (from[1] == to[1] and from[2] > to[2]) then
					from, to = to, from
				end

				require("opencode.server.discovery")
					.get()
					:next(function(server)
						local context = require("opencode.context").new(server, {
							from = { from[1], from[2] },
							to = { to[1], to[2] },
							kind = kind,
						})
						local ref = context:render("@this").output:plaintext()
						-- Context.new highlights the range with a persistent "Visual" extmark; clear it
						-- now that the ref is captured, mirroring the plugin's prompt lifecycle.
						context:clear()
						if ref then
							if not require("opencode.translator.composer").add_ref(ref) then
								vim.notify("no composer open", vim.log.levels.WARN, { title = "opencode translator" })
							end
						else
							vim.notify("no ref for buffer", vim.log.levels.WARN, { title = "opencode translator" })
						end
					end)
					:catch(function(err)
						vim.notify(tostring(err), vim.log.levels.ERROR, { title = "opencode translator" })
					end)
			end
			vim.o.operatorfunc = "v:lua.opencode_composer_ref_operator"
		end

		vim.keymap.set({ "n", "x" }, "<leader>ap", function()
			composer_ref_operator()
			return "g@"
		end, { desc = "Add range ref to composer", expr = true })
		vim.keymap.set({ "n", "x" }, "<leader>ao", function()
			composer_ref_operator()
			return "g@_"
		end, { desc = "Add line ref to composer", expr = true })

		vim.keymap.set({ "n", "x" }, "<leader>as", function()
			require("opencode").select()
		end, { desc = "Execute opencode action…" })
		vim.keymap.set({ "n", "t" }, "<C-,>", function()
			require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
		end, { desc = "Toggle opencode" })

		vim.keymap.set({ "n", "x" }, "<leader>ar", function()
			return require("opencode").operator("@this ")
		end, { desc = "Add range to opencode", expr = true })
		vim.keymap.set("n", "<leader>al", function()
			return require("opencode").operator("@this ") .. "_"
		end, { desc = "Add line to opencode", expr = true })

		vim.keymap.set("n", "<S-C-u>", function()
			require("opencode").command("session.half.page.up")
		end, { desc = "Scroll opencode up" })
		vim.keymap.set("n", "<S-C-d>", function()
			require("opencode").command("session.half.page.down")
		end, { desc = "Scroll opencode down" })
		vim.keymap.set("n", "<leader>at", function()
			require("opencode.translator").toggle()
		end, { desc = "Toggle opencode translator" })
	end,
}
