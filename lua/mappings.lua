require("nvchad.mappings")
-- local map = vim.keymap.set
local map = vim.keymap
-- pcall protected call, doesnt error if keymap has already been removed (useful when calling :ReloadKeymaps)
local del = function(mode, keymap)
	pcall(vim.keymap.del, mode, keymap)
end

map.set("n", "<C-i>", "<C-i>")
map.set("n", "<C-o>", "<C-o>")
-- <C-x> - Exit terminal mode (alternative to <C-\><C-n>)

-- These are defined in NvChad's default mappings. Want me to add some additional convenient terminal keybindings, like:
-- - <leader>th - Horizontal terminal
-- - <leader>tv - Vertical terminal
-- - <leader>tf - Floating terminal
-- - <C-/> - Toggle terminal (like VSCode)
-- Disable NvChad's default <leader>x (close buffer) - we use Trouble with <leader>x now
del("n", "<leader>x")
-- Disable NvChad's line number toggle
del("n", "<leader>n")
-- Disable NvChad's terminal toggles that conflict with FzfLua
del("n", "<A-i>") -- floating terminal
del("n", "<A-h>") -- horizontal terminal
del("n", "<A-v>") -- vertical terminal
del("t", "<A-i>") -- terminal mode
del("t", "<A-h>")
del("t", "<A-v>")
del("n", "<leader>b") -- disable NvChad's new buffer keybind

-- NvChad's <leader>h (horizontal terminal) is overridden by Harpoon's quick menu in plugins/harpoon.lua
-- Terminal toggle with Ctrl+/
map.set({ "n", "t" }, "<C-/>", function()
	require("nvchad.term").toggle({ pos = "sp", id = "htoggleTerm" })
end, { desc = "Toggle horizontal terminal" })

map.set({ "n", "t" }, "<C-\\>", function()
	require("nvchad.term").toggle({ pos = "vsp", id = "vtoggleTerm", size = 0.4 })
end, { desc = "Toggle vertical terminal" })

-- map.set("n", ";", ":", { desc = "CMD enter command mode" })

map.set({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Override NvChad's <leader>e to toggle instead of just focus
map.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })

map.set("n", "<leader>c]", function()
	require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
end, { desc = "Swap with previous parameter" })
map.set("n", "<leader>c[", function()
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
map.set("i", "<S-Tab>", "<C-d>", { desc = "Outdent line" })

-- Split a line at cursor position. Opposite of J in normal mode which join line below to current line.
-- vim.keymap.set({ "n", "v" }, "<C-;>", "i<CR><Esc>", { noremap = true, desc = "Split line at cursor" })

-- Vim Diff Navigation (for :diffthis, :diffsplit, etc.)
map.set({ "n", "v" }, "]x", function()
	if vim.wo.diff then
		vim.cmd.normal({ "]c", bang = true })
	end
end, { desc = "Next Diff Change" })

map.set({ "n", "v" }, "[x", function()
	if vim.wo.diff then
		vim.cmd.normal({ "[c", bang = true })
	end
end, { desc = "Previous Diff Change" })

-- Git Hunk Navigation (Gitsigns)
map.set({ "n", "v" }, "]h", function()
	if vim.wo.diff then
		return
	end
	require("gitsigns").nav_hunk("next")
end, { desc = "Next Git Hunk" })

map.set({ "n", "v" }, "[h", function()
	if vim.wo.diff then
		return
	end
	require("gitsigns").nav_hunk("prev")
end, { desc = "Previous Git Hunk" })

map.set({ "n", "v" }, "]H", function()
	require("gitsigns").nav_hunk("last")
end, { desc = "Last Git Hunk" })

map.set({ "n", "v" }, "[H", function()
	require("gitsigns").nav_hunk("first")
end, { desc = "First Git Hunk" })

-- Git Hunk Actions
map.set({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", { desc = "Stage Hunk" })
map.set({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", { desc = "Reset Hunk" })
map.set("n", "<leader>ghS", "<cmd>Gitsigns stage_buffer<CR>", { desc = "Stage Buffer" })
map.set("n", "<leader>ghu", "<cmd>Gitsigns undo_stage_hunk<CR>", { desc = "Undo Stage Hunk" })
map.set("n", "<leader>ghR", "<cmd>Gitsigns reset_buffer<CR>", { desc = "Reset Buffer" })
map.set("n", "<leader>ghd", "<cmd>Gitsigns diffthis<CR>", { desc = "Diff This" })
map.set("n", "<leader>ghb", "<cmd>Gitsigns blame<CR>", { desc = "Blame Line" })
map.set("n", "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle Inline Git Blame" })

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

-- DiffView (Git diffs)
map.set("n", "<leader>DO", "<cmd>DiffviewOpen<cr>", { desc = "Open Diffview" })
map.set("n", "<leader>DD", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" })
map.set("n", "<leader>gdh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File History (current)" })
map.set("v", "<leader>gdh", ":'<,'>DiffviewFileHistory<cr>", { desc = "File History (selection)" })
map.set("n", "<leader>gdH", "<cmd>DiffviewFileHistory<cr>", { desc = "File History (all)" })
map.set("n", "<leader>gdm", "<cmd>DiffviewOpen HEAD<cr>", { desc = "Diff uncommited changes" })
map.set("n", "<leader>gdM", "<cmd>DiffviewOpen HEAD~1<cr>", { desc = "Diff last commit" })
map.set("n", "<leader>gdb", function()
	vim.ui.input({ prompt = "Compare branch: " }, function(branch)
		if branch then
			vim.cmd("DiffviewOpen " .. branch)
		end
	end)
end, { desc = "Diff with branch" })

-- Smart diff against base branch (main/master/develop)
map.set("n", "<leader>gdd", function()
	-- Check remote branches first (more accurate), then local
	local base_candidates = {
		"origin/main",
		"origin/master",
		"main",
		"master",
	}

	local base_branch = nil
	for _, branch in ipairs(base_candidates) do
		local result = vim.fn.system("git rev-parse --verify " .. branch .. " 2>/dev/null")
		if vim.v.shell_error == 0 then
			base_branch = branch
			break
		end
	end

	if not base_branch then
		vim.notify("Could not find base branch", vim.log.levels.WARN)
		return
	end

	-- Use three-dot syntax to diff against merge-base (where we branched from)
	vim.cmd("DiffviewOpen " .. base_branch .. "...")
	vim.notify("Comparing against " .. base_branch, vim.log.levels.INFO)
end, { desc = "Diff from base branch" })

-- File Diffing (non-git)
map.set("n", "<leader>gdf", function()
	require("fzf-lua").files({
		prompt = "Diff current file with: ",
		actions = {
			["default"] = function(selected, opts)
				if selected and #selected > 0 then
					local file = require("fzf-lua").path.entry_to_file(selected[1], opts)
					vim.cmd("vertical diffsplit " .. vim.fn.fnameescape(file.path))
				end
			end,
		},
	})
end, { desc = "Diff current file (picker)" })
-- map.set("n", "<leader>gdb", function()
--     require("fzf-lua").buffers({
--         prompt = "Diff current file with buffer: ",
--         actions = {
--             ["default"] = function(selected)
--                 if selected and selected[1] then
--                     local bufnr = selected[1]:match("^%[(%d+)")
--                     if bufnr then
--                         vim.cmd("vertical diffsplit #" .. bufnr)
--                     end
--                 end
--             end
--         }
--     })
-- end, { desc = "Diff with buffer (picker)" })

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
vim.api.nvim_create_user_command("ReloadKeymaps", "luafile ~/.config/nvim/lua/mappings.lua", {})
vim.api.nvim_create_user_command("ReloadOptions", "luafile ~/.config/nvim/lua/options.lua", {})

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
map.set({ "n", "v", "o", "i" }, "<C-c>", smart_cancel, {
	expr = true, -- This is crucial: it executes the function to get the keys to press.
	silent = true,
	desc = "Smart Cancel (clears which-key)",
})

-- Buffer management (LazyVim style)
local function delete_buffer(force)
	local buf = vim.api.nvim_get_current_buf()
	local listed_buffers = vim.tbl_filter(function(b)
		return vim.bo[b].buflisted and b ~= buf
	end, vim.api.nvim_list_bufs())

	-- If there are other buffers, switch to one of them
	if #listed_buffers > 0 then
		vim.cmd("bprevious")
	else
		-- If this is the only buffer, create a new empty one first
		vim.cmd("enew")
	end

	-- Delete the original buffer
	local delete_cmd = force and "bdelete!" or "bdelete"
	vim.cmd(delete_cmd .. " " .. buf)
end

map.set("n", "<leader>bd", function()
	require("nvchad.tabufline").close_buffer()
end, { desc = "Delete Buffer" })
map.set("n", "<leader>bn", ":enew<cr>", { desc = "Delete Buffer" })
map.set("n", "<leader>bD", function()
	delete_buffer(true)
end, { desc = "Delete Buffer (force)" })
map.set("n", "<leader>bo", function()
	require("nvchad.tabufline").closeAllBufs(false) -- keeps open buffer
end, { desc = "Delete Other Buffers" })
map.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map.set("n", "<S-h>", function()
	require("nvchad.tabufline").prev()
end, { desc = "Previous Buffer" })
map.set("n", "<S-l>", function()
	require("nvchad.tabufline").next()
end, { desc = "Next Buffer" })

map.set("n", "<leader>uw", ":set wrap!<CR>", { desc = "Toggle word wrap" })

-- View messages (LazyVim style)
map.set("n", "<leader>n", ":messages<cr>", { desc = "Messages" })

-- Copy relative file path
map.set("n", "<leader>fc", function()
	local path = vim.fn.expand("%")
	vim.fn.setreg("+", path)
	vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy relative file path" })
