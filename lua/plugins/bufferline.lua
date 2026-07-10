return {
	"akinsho/bufferline.nvim",
	opts = function(_, opts)
		opts.options = opts.options or {}
		opts.options.always_show_bufferline = true
		opts.options.custom_filter = function(buf_number)
			local tab_bufs = vim.t.bufs
			if tab_bufs then
				for _, b in ipairs(tab_bufs) do
					if b == buf_number then
						return true
					end
				end
				return false
			end
			return true
		end
	end,
	init = function()
		-- Force bufferline to render immediately after startup so showtabline=2
		-- is applied even before any buffer events fire.
		vim.api.nvim_create_autocmd("VimEnter", {
			once = true,
			callback = function()
				vim.schedule(function()
					vim.o.showtabline = 2
				end)
			end,
		})
	end,
}
