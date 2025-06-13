-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap

-- remove default mapping which opens Help. can still access with :help
map.set({ "v", "n", "i", "c" }, "<F1>", "<Nop>")

-- rebind deletions to black hole register _
map.set({ "n", "v" }, "x", '"_x', { noremap = true })
map.set({ "n", "v" }, "X", '"_dd', { noremap = true })
map.set({ "n", "v" }, "D", '"_D', { noremap = true })
-- map.set({ "n", "v" }, "dd", '"_dd', { noremap = true })
map.set({ "n", "v" }, "C", '"_C', { noremap = true })
map.set({ "n", "v" }, "c", '"_c', { noremap = true })

-- Changes P behaviour to pasting from the 0 register rather than the last thing yanked
-- map.set({ "n", "v" }, "P", '"0p', { noremap = true })
map.set({ "n", "v" }, "<C-p>", '"0P', { noremap = true })
-- copy to system clipboard
map.set({ "n", "v" }, "Y", '"+y', { noremap = true })

-- jumps back to first char on line, also equivalent to hitting ^
map.set({ "n", "v" }, "-", "_", { noremap = true })

-- comfy horizontal scrolling
map.set({ "n", "v" }, "zl", "zL", { noremap = true })
map.set({ "n", "v" }, "zh", "zH", { noremap = true })

-- Insert mode settings
-- outdent line to the left
vim.keymap.set("i", "<S-Tab>", "<C-d>", { desc = "Outdent line" })

-- Git
map.set({ "n", "v" }, "<leader>gn", function()
    require("fzf-lua").git_blame()
end, { noremap = true, silent = true, desc = "Git FZF Blame buffer" })
map.set({ "n", "v" }, "<leader>gs", function()
    require("fzf-lua").git_status()
end, { noremap = true, silent = true, desc = "Git FZF status" })
map.set({ "n", "v" }, "<leader>gC", function()
    require("fzf-lua").git_status()
end, { noremap = true, silent = true, desc = "Git buffer commit log" })

-- DiffView
map.set(
    { "n", "v" },
    "<leader>gH",
    [[:DiffviewFileHistory<CR>]],
    { noremap = true, silent = true, desc = "DiffView File History (selection)" }
)
map.set({ "n", "v" }, "<leader>DD", [[:DiffviewClose<CR>]], { noremap = true, silent = true, desc = "DiffViewClose" })
map.set({ "n", "v" }, "<leader>DO", [[:DiffviewOpen<CR>]], { noremap = true, silent = true, desc = "DiffViewOpen" })

-- persistent breakpoints plugin
-- Save breakpoints to file automatically.
map.set(
    { "n", "v" },
    "<leader>dd",
    "<cmd>lua require('persistent-breakpoints.api').toggle_breakpoint()<cr>",
    { noremap = true, silent = true, desc = "Toggle Breakpoint" }
)
map.set(
    { "n", "v" },
    "<leader>dD",
    "<cmd>lua require('persistent-breakpoints.api').set_conditional_breakpoint()<cr>",
    { noremap = true, silent = true, desc = "Breakpoint Condition" }
)
map.set(
    { "n", "v" },
    "<leader>dX",
    "<cmd>lua require('persistent-breakpoints.api').clear_all_breakpoints()<cr>",
    { noremap = true, silent = true, desc = "Clear all breakpoints" }
)
map.set(
    { "n", "v" },
    "<leader>df",
    "<cmd>lua require('persistent-breakpoints.api').set_log_point()<cr>",
    { noremap = true, silent = true, desc = "Set Log Point" }
)

-- Add custom command to reload key mapping file
vim.api.nvim_create_user_command("ReloadKeymaps", "luafile ~/.config/nvim/lua/config/keymaps.lua", {})
vim.api.nvim_create_user_command("ReloadOptions", "luafile ~/.config/nvim/lua/config/options.lua", {})
