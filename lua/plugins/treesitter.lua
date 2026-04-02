local function is_large_file(buf)
	local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
	return ok and stats and stats.size > 1024 * 1024 -- 1MB
end

return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	branch = "main",
	-- commit = "cc12e37e5bdc5467c9a06ab9b0887a97758f567f",
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
			disable = function(_, buf)
				return is_large_file(buf)
			end,
		},
		indent = {
			enable = true,
			disable = function(_, buf)
				return is_large_file(buf)
			end,
		},
	},
}
