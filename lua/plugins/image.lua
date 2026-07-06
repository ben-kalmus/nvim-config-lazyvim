return {
	"3rd/image.nvim",
	enabled = true,
	event = "VeryLazy",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		local image = require("image")

		image.setup({
			backend = "kitty",
			integrations = {
				markdown = {
					enabled = true,
					clear_in_insert_mode = true,
					download_remote_images = true,
					only_render_image_at_cursor = true, -- only show image under cursor
					filetypes = { "markdown", "vimwiki" },
				},
				neorg = {
					enabled = false,
				},
				html = {
					enabled = false,
				},
				css = {
					enabled = false,
				},
			},
			max_width = nil,
			max_height = nil,
			max_width_window_percentage = 80,
			max_height_window_percentage = 50,
			window_overlap_clear_enabled = true, -- auto clear images when windows overlap
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "scrollview", "scrollview_sign" },
			editor_only_render_when_focused = true, -- hide images when losing focus
			tmux_show_only_in_active_window = false,
			hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
		})

		-- Clear images when floating windows open
		local group = vim.api.nvim_create_augroup("ImageNvimFloatingClear", { clear = true })

		-- Clear on telescope/picker
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			pattern = { "TelescopePrompt", "TelescopeResults", "fzf" },
			callback = function()
				image.clear()
			end,
		})

		-- Clear on lazygit
		vim.api.nvim_create_autocmd("TermOpen", {
			group = group,
			pattern = "*lazygit*",
			callback = function()
				image.clear()
			end,
		})

		-- Clear when any floating window opens
		vim.api.nvim_create_autocmd("WinEnter", {
			group = group,
			callback = function()
				if vim.api.nvim_win_get_config(0).relative ~= "" then
					image.clear()
				end
			end,
		})

		-- Toggle functionality
		_G.image_nvim_enabled = true

		_G.toggle_image_nvim = function()
			_G.image_nvim_enabled = not _G.image_nvim_enabled
			if _G.image_nvim_enabled then
				vim.notify("Image rendering enabled", vim.log.levels.INFO)
			else
				image.clear()
				vim.notify("Image rendering disabled", vim.log.levels.WARN)
			end
		end
	end,
	keys = {
		{
			"<leader>i",
			function()
				_G.toggle_image_nvim()
			end,
			desc = "Toggle Image Rendering",
		},
	},
}
