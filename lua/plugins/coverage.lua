return {
	"mr-u0b0dy/crazy-coverage.nvim",
	opts = {
		enable_line_hl = true,
		hit_count = { show_by_default = true, display = "eol" },
		show_coverage_in_sign_column = false,
		auto_adapt_colors = true,
	},
	keys = {
		{ "GC", "<cmd>CoverageToggle<CR>", desc = "Coverage: Toggle", ft = "go" },
		{ "GS", "<cmd>CoverageSummary<CR>", desc = "Coverage: Summary", ft = "go" },
	},
}
