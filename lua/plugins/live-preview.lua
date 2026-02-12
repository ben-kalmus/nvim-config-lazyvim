-- Find next available port starting from 5500
local function is_port_available(port)
	local tcp = vim.loop.new_tcp()
	local ok = tcp:bind("127.0.0.1", port)
	tcp:close()
	return ok
end

return {
	"brianhuster/live-preview.nvim",
	event = "VeryLazy",
	dependencies = {
		"ibhagwan/fzf-lua",
	},
	keys = {
		{
			"<leader>ml",
			function()
				local port = 5500
				while not is_port_available(port) and port < 5600 do
					port = port + 1
				end

				if port >= 5600 then
					vim.notify("No available ports found between 5500-5600", vim.log.levels.ERROR)
					return
				end

				-- Update port dynamically and start preview
				LivePreview.config.port = port
				if port ~= 5500 then
					vim.notify(string.format("Port 5500 in use, using port %d instead", port), vim.log.levels.INFO)
				end
				vim.cmd("LivePreview start")
			end,
			desc = "Live Preview (mermaid support)",
			ft = { "markdown", "html" },
		},
	},
	config = function()
		require("livepreview.config").set({
			port = 5500, -- Starting port for preview server
			browser = "default", -- 'default' or command like 'firefox'
			dynamic_root = false, -- false = use cwd, true = use parent dir of file
			sync_scroll = true, -- Sync browser scroll with nvim scroll
			picker = "fzf", -- 'telescope', 'fzf', 'mini.pick', 'snacks', or vim.ui.select
			address = "127.0.0.1", -- Server bind address
		})
	end,
}
