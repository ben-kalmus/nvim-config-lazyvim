-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap

-- remove default mapping which opens Help. can still access with :help
map.set({ "v", "n", "i", "c" }, "<F1>", "<Nop>")
map.set({ "n", "v" }, "<F1>", function()
    require("dap").step_into()
end, { desc = "Step Into F1" })

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

-- Split a line at cursor position: opposite of normal mode (capital) `J`
vim.keymap.set({ "n", "v" }, "<C-J>", "i<CR><Esc>", { noremap = true, desc = "Split line at cursor" })

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

local function smart_cancel()
    local mode = vim.fn.mode()

    -- If we are in operator-pending mode (e.g., after pressing 'c', 'd', or 'y'),
    -- we must send <Esc> to cancel the operation fully.
    if mode == "o" or mode == "ov" then
        return "<Esc>"
    end

    -- In insert, command, or select mode, <C-c> is the more appropriate cancel.
    if mode == "i" or mode == "ic" or mode == "s" or mode == "c" then
        return "<C-c>"
    end

    -- In any other mode (normal, visual), just send <Esc>.
    return "<Esc>"
end

-- Now, we remap <C-c> in the most important modes to use our smart function.
-- { 'n', 'v', 'o', 'i' } covers normal, visual, operator-pending, and insert.
vim.keymap.set({ "n", "v", "o", "i" }, "<C-c>", smart_cancel, {
    expr = true, -- This is crucial: it executes the function to get the keys to press.
    silent = true,
    desc = "Smart Cancel (clears which-key)",
})
