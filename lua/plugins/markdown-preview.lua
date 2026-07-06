return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	event = "VeryLazy",
	build = function()
		require("lazy").load({ plugins = { "markdown-preview.nvim" } })
		vim.fn["mkdp#util#install"]()
	end,
	keys = {
		{
			"<leader>mm",
			ft = "markdown",
			"<cmd>MarkdownPreviewToggle<cr>",
			desc = "Markdown Preview",
		},
	},
	-- `init` runs before the plugin is loaded, `config` runs asfter.
	init = function()
		vim.g.mkdp_auto_close = 0
		vim.g.mkdp_port = "8123"
		vim.g.mkdp_theme = "dark"
		vim.g.mkdp_refresh_slow = 1

		-- vim.cmd([[do FileType]])
	end,
}
