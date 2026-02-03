require "nvchad.mappings"

  -- NvChad terminal toggles:
  -- - Alt+h - Toggle horizontal terminal
  -- - Alt+v - Toggle vertical terminal
  -- - Alt+i - Toggle floating terminal

  -- In terminal mode:
  -- - Alt+h/v/i - Toggle back to normal mode
  -- - <C-x> - Exit terminal mode (alternative to <C-\><C-n>)

  -- These are defined in NvChad's default mappings. Want me to add some additional convenient terminal keybindings, like:
  -- - <leader>th - Horizontal terminal
  -- - <leader>tv - Vertical terminal
  -- - <leader>tf - Floating terminal
  -- - <C-/> - Toggle terminal (like VSCode)

-- Disable NvChad's default <leader>x (close buffer) - we use Trouble with <leader>x now
vim.keymap.del("n", "<leader>x")

-- add yours here
-- local map = vim.keymap.set
local map = vim.keymap


map.set("n", ";", ":", { desc = "CMD enter command mode" })
map.set("i", "jk", "<ESC>")

map.set({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Override NvChad's <leader>e to toggle instead of just focus
map.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })

-- Terminal toggle with Ctrl+/ (like VSCode)
map.set({ "n", "t" }, "<C-/>", function()
  require("nvchad.term").toggle({ pos = "sp", id = "htoggleTerm" })
end, { desc = "Toggle horizontal terminal" })

vim.keymap.set("n", "<leader>c]", function()
    require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
end, { desc = "Swap with previous parameter" })
vim.keymap.set("n", "<leader>c[", function()
    require("nvim-treesitter-textobjects.swap").swap_next("@parameter.outer")
end, { desc = "Swap with next parameter" })

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

-- Split a line at cursor position. Opposite of J in normal mode which join line below to current line.
-- vim.keymap.set({ "n", "v" }, "<C-;>", "i<CR><Esc>", { noremap = true, desc = "Split line at cursor" })

-- Git Hunk Navigation (Gitsigns)
map.set("n", "]h", function()
    if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
    else
        require("gitsigns").nav_hunk("next")
    end
end, { desc = "Next Git Hunk" })

map.set("n", "[h", function()
    if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
    else
        require("gitsigns").nav_hunk("prev")
    end
end, { desc = "Previous Git Hunk" })

map.set("n", "]H", function()
    require("gitsigns").nav_hunk("last")
end, { desc = "Last Git Hunk" })

map.set("n", "[H", function()
    require("gitsigns").nav_hunk("first")
end, { desc = "First Git Hunk" })

-- Git Hunk Actions
map.set({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", { desc = "Stage Hunk" })
map.set({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", { desc = "Reset Hunk" })
map.set("n", "<leader>ghS", "<cmd>Gitsigns stage_buffer<CR>", { desc = "Stage Buffer" })
map.set("n", "<leader>ghu", "<cmd>Gitsigns undo_stage_hunk<CR>", { desc = "Undo Stage Hunk" })
map.set("n", "<leader>ghR", "<cmd>Gitsigns reset_buffer<CR>", { desc = "Reset Buffer" })
map.set("n", "<leader>ghd", "<cmd>Gitsigns diffthis<CR>", { desc = "Diff This" })
map.set("n", "<leader>ghb", "<cmd>Gitsigns blame_line<CR>", { desc = "Blame Line" })

-- Git (other)
map.set({ "n", "v" }, "<leader>gn", function()
    require("fzf-lua").git_blame()
end, { noremap = true, silent = true, desc = "Git FZF Blame buffer" })
map.set({ "n", "v" }, "<leader>gs", function()
    require("fzf-lua").git_status()
end, { noremap = true, silent = true, desc = "Git FZF status" })
map.set({ "n", "v" }, "<leader>gC", function()
    require("fzf-lua").git_status()
end, { noremap = true, silent = true, desc = "Git buffer commit log" })
-- Shows diff of the current line.
map.set(
    { "n", "v" },
    "<leader>gp",
    [[:Gitsigns preview_hunk_inline<CR>]],
    { noremap = true, silent = true, desc = "Git preview hunk diff" }
)

-- Git Worktrees (lua plugin)
map.set({ "n", "v" }, "<leader>gwc", function()
    vim.ui.input({ prompt = "Enter worktree name: " }, function(input)
        if input and input ~= "" then
            require("git-worktree").create_worktree(input)
        end
    end)
end, { noremap = true, silent = true, desc = "Create git worktree" })

map.set({ "n", "v" }, "<leader>gws", function()
    vim.ui.input({ prompt = "Switch to worktree: " }, function(input)
        if input and input ~= "" then
            require("git-worktree").switch_worktree(input)
        end
    end)
end, { noremap = true, silent = true, desc = "Switch to worktree" })

map.set({ "n", "v" }, "<leader>gwd", function()
    vim.ui.input({ prompt = "Delete worktree: " }, function(input)
        if input and input ~= "" then
            require("git-worktree").delete_worktree(input)
        end
    end)
end, { noremap = true, silent = true, desc = "Delete git worktree" })

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

-- bufferline tab switching
map.set({ "n", "v" }, "<leader>wn", [[:tabnew<CR>]], { noremap = true, silent = true, desc = "Create new tab" })
map.set({ "n", "v" }, "<leader>wc", [[:tabclose<CR>]], { noremap = true, silent = true, desc = "Close current tab" })

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

-- Buffer management (LazyVim style)
map.set("n", "<leader>bd", "<cmd>bd<cr>", { desc = "Delete Buffer" })
map.set("n", "<leader>bD", "<cmd>bd!<cr>", { desc = "Delete Buffer (force)" })
map.set("n", "<leader>bo", "<cmd>%bd|e#|bd#<cr>", { desc = "Delete Other Buffers" })
map.set("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })
map.set("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map.set("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })
map.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
