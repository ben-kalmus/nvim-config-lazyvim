return {
	"3rd/diagram.nvim",
	enabled = false,
	dependencies = {
		"3rd/image.nvim",
	},
	ft = { "markdown", "neorg" },
	opts = {
		renderer_options = {
			mermaid = {
				theme = "dark", -- Options: 'default', 'dark', 'forest', 'neutral'
				background = "#aaaaaa", -- nil for transparent, or color like '#1e1e1e'
				scale = 1,
			},
		},
	},
	keys = {
		{
			"<leader>md",
			"<cmd>lua require('diagram').show_diagram_hover()<cr>",
			desc = "Show Diagram in Hover",
			ft = { "markdown", "neorg" },
		},
	},
}
