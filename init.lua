-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- virtual environment for python3 with pynvim installation
vim.g.python3_host_prog = vim.fn.expand("~/.config/nvim/venv/bin/python3")
