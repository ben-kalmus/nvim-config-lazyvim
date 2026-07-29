return {
	-- Prevent LazyVim's base UI spec from installing or configuring Bufferline.
	{ "akinsho/bufferline.nvim", enabled = false },
	{
		"nvim-mini/mini.tabline",
		version = false,
		config = function()
			require("mini.tabline").setup({ show_icons = false })
		end,
	},
}
