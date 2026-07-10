return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	ft = { "markdown" },
	opts = {
		-- Headings - different icons and colors
		heading = {
			-- Enable heading rendering
			enabled = true,
			-- Icons for each heading level
			icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
			-- Highlight groups for each level
			backgrounds = {
				"RenderMarkdownH1Bg",
				"RenderMarkdownH2Bg",
				"RenderMarkdownH3Bg",
				"RenderMarkdownH4Bg",
				"RenderMarkdownH5Bg",
				"RenderMarkdownH6Bg",
			},
			foregrounds = {
				"RenderMarkdownH1",
				"RenderMarkdownH2",
				"RenderMarkdownH3",
				"RenderMarkdownH4",
				"RenderMarkdownH5",
				"RenderMarkdownH6",
			},
		},
		-- Code blocks
		code = {
			enabled = true,
			sign = true,
			style = "full", -- 'full', 'normal', 'language', or 'none'
			position = "left",
			width = "block", -- 'full' or 'block'
			left_pad = 0,
			right_pad = 0,
			border = "thin", -- 'thin' or 'thick'
		},
		-- Inline code
		inline_code = {
			enabled = true,
		},
		-- Dashes/horizontal rules
		dash = {
			enabled = true,
			icon = "─",
			width = "full",
		},
		-- Bullet points
		bullet = {
			enabled = true,
			icons = { "●", "○", "◆", "◇" },
		},
		-- Checkboxes
		checkbox = {
			enabled = true,
			unchecked = {
				icon = "󰄱 ",
				highlight = "RenderMarkdownUnchecked",
			},
			checked = {
				icon = "󰱒 ",
				highlight = "RenderMarkdownChecked",
			},
			custom = {
				todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
			},
		},
		-- Block quotes
		quote = {
			enabled = true,
			icon = "▋",
			repeat_linebreak = false,
		},
		-- Tables
		pipe_table = {
			enabled = true,
			style = "full", -- 'full', 'normal', or 'none'
			cell = "padded",
			border = {
				"┌",
				"┬",
				"┐",
				"├",
				"┼",
				"┤",
				"└",
				"┴",
				"┘",
				"│",
				"─",
			},
		},
		-- Callouts/admonitions (Github-style and Obsidian-style)
		callout = {
			note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
			tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
			important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
			warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
			caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
			-- Obsidian style
			abstract = { raw = "[!ABSTRACT]", rendered = "󰨸 Abstract", highlight = "RenderMarkdownInfo" },
			todo = { raw = "[!TODO]", rendered = "󰗡 Todo", highlight = "RenderMarkdownInfo" },
			success = { raw = "[!SUCCESS]", rendered = "󰄬 Success", highlight = "RenderMarkdownSuccess" },
			question = { raw = "[!QUESTION]", rendered = "󰘥 Question", highlight = "RenderMarkdownWarn" },
			failure = { raw = "[!FAILURE]", rendered = "󰅖 Failure", highlight = "RenderMarkdownError" },
			danger = { raw = "[!DANGER]", rendered = "󱐌 Danger", highlight = "RenderMarkdownError" },
			bug = { raw = "[!BUG]", rendered = "󰨰 Bug", highlight = "RenderMarkdownError" },
			example = { raw = "[!EXAMPLE]", rendered = "󰉹 Example", highlight = "RenderMarkdownHint" },
			quote = { raw = "[!QUOTE]", rendered = "󱆨 Quote", highlight = "RenderMarkdownQuote" },
		},
		-- Links
		link = {
			enabled = true,
			image = "󰥶 ",
			hyperlink = "󰌹 ",
			highlight = "RenderMarkdownLink",
		},
		-- Window options
		win_options = {
			conceallevel = {
				default = vim.api.nvim_get_option_value("conceallevel", {}),
				rendered = 3,
			},
			concealcursor = {
				default = vim.api.nvim_get_option_value("concealcursor", {}),
				rendered = "",
			},
		},
	},
	config = function(_, opts)
		require("render-markdown").setup(opts)

		-- Keybindings
		vim.keymap.set("n", "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle Markdown Rendering" })
	end,
}
