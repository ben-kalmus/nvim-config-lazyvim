return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	-- branch = "main",
	commit = "cc12e37e5bdc5467c9a06ab9b0887a97758f567f",
	opts = {
		ensure_installed = {
			"lua",
			"vim",
			"vimdoc",
			"python",
			"go",
			"javascript",
			"typescript",
			"tsx",
			"html",
			"css",
			"json",
			"yaml",
			"bash",
			"markdown",
			"markdown_inline",
			"toml",
		},
		auto_install = true,
		highlight = {
			enable = true,
			-- additional_vim_regex_highlighting = false,
		},
		indent = {
			enable = true,
		},
	},
}
