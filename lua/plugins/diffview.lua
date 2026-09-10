return {
	"dlyongemallo/diffview-plus.nvim",
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewToggleFiles",
		"DiffviewFocusFiles",
		"DiffviewFileHistory",
		"DiffviewMergeFiles",
		"DiffviewDiffDirs",
		"DiffviewRefresh",
	},
	opts = {
		enhanced_diff_hl = true,
		use_icons = false,
		show_help_hints = false,
		watch_index = false,
		large_file_threshold = 2000,
		diffopt = {
			algorithm = "histogram",
			indent_heuristic = true,
			linematch = 60,
			context = 3,
		},
		persist_selections = {
			enabled = true,
		},
		default_args = {
			DiffviewOpen = { "--imply-local" },
		},
		view = {
			default = {
				winbar_info = true,
				disable_diagnostics = true,
			},
			file_history = {
				winbar_info = true,
				disable_diagnostics = true,
			},
			merge_tool = {
				layout = "diff3_mixed",
			},
			foldlevel = 0,
			cycle_layouts = {
				default = { "diff2_horizontal", "diff2_vertical", "diff1_inline" },
			},
			inline = {
				style = "unified",
				fold_unchanged = true,
				deletion_treesitter = false,
			},
		},
		file_panel = {
			listing_style = "tree", -- One of 'list' or 'tree'
			tree_options = { -- Only applies when listing_style is 'tree'
				flatten_dirs = true, -- Flatten dirs that only contain one single dir
				folder_statuses = "never", -- One of 'never', 'only_folded' or 'always'.
			},
			win_config = { -- See |diffview-config-win_config|
				position = "left",
				width = 35,
				win_opts = {},
			},
		},
		file_history_panel = {
			log_options = {
				git = {
					single_file = { max_count = 256, follow = true },
					multi_file = { max_count = 256 },
				},
			},
		},
	},
}
