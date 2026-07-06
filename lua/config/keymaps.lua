-- Keymaps are automatically loaded by LazyVim.

local map = vim.keymap.set
local del = function(mode, lhs)
  pcall(vim.keymap.del, mode, lhs)
end

map("n", "<C-i>", "<C-i>")
map("n", "<C-o>", "<C-o>")
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>", { desc = "Save File" })

-- Snacks-first UI replacements for old NvChad bindings.
map("n", "<leader>e", function()
  Snacks.explorer()
end, { desc = "Explorer" })

map({ "n", "t" }, "<C-/>", function()
  Snacks.terminal.toggle(nil, { win = { position = "bottom" } })
end, { desc = "Toggle Horizontal Terminal" })

map({ "n", "t" }, "<C-\\>", function()
  Snacks.terminal.toggle(nil, { win = { position = "right", width = 0.4 } })
end, { desc = "Toggle Vertical Terminal" })

map("n", "<leader>c]", function()
  require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
end, { desc = "Swap With Next Parameter" })
map("n", "<leader>c[", function()
  require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
end, { desc = "Swap With Previous Parameter" })

map({ "v", "n", "i", "c" }, "<F1>", "<Nop>")
map({ "n", "v" }, "<F1>", function()
  require("dap").step_into()
end, { desc = "Step Into" })

-- Editing ergonomics.
map({ "n", "v" }, "x", '"_x', { noremap = true })
map({ "n", "v" }, "X", '"_dd', { noremap = true })
map({ "n", "v" }, "D", '"_D', { noremap = true })
map({ "n", "v" }, "C", '"_C', { noremap = true })
map({ "n", "v" }, "c", '"_c', { noremap = true })
map({ "n", "v" }, "<C-p>", '"0P', { noremap = true })
map({ "n", "v" }, "Y", '"+y', { noremap = true })
map({ "n", "v" }, "-", "_", { noremap = true })
map({ "n", "v" }, "zl", "zL", { noremap = true })
map({ "n", "v" }, "zh", "zH", { noremap = true })
map("i", "<S-Tab>", "<C-d>", { desc = "Outdent Line" })

-- Terminal navigation and word movement.
map("t", "<C-x>", "<C-\\><C-n>", { desc = "Terminal Normal Mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Move to Left Window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Move to Window Below" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Move to Window Above" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Move to Right Window" })
map("t", "<C-Left>", function()
  vim.fn.chansend(vim.b.terminal_job_id, "\27b")
end, { desc = "Word Left in Terminal" })
map("t", "<C-Right>", function()
  vim.fn.chansend(vim.b.terminal_job_id, "\27f")
end, { desc = "Word Right in Terminal" })

-- Diff and Git hunk navigation.
map({ "n", "v" }, "]x", function()
  if vim.wo.diff then
    vim.cmd.normal({ "]c", bang = true })
  end
end, { desc = "Next Diff Change" })
map({ "n", "v" }, "[x", function()
  if vim.wo.diff then
    vim.cmd.normal({ "[c", bang = true })
  end
end, { desc = "Previous Diff Change" })

map({ "n", "v" }, "]h", function()
  if not vim.wo.diff then
    require("gitsigns").nav_hunk("next")
  end
end, { desc = "Next Git Hunk" })
map({ "n", "v" }, "[h", function()
  if not vim.wo.diff then
    require("gitsigns").nav_hunk("prev")
  end
end, { desc = "Previous Git Hunk" })
map({ "n", "v" }, "]H", function()
  require("gitsigns").nav_hunk("last")
end, { desc = "Last Git Hunk" })
map({ "n", "v" }, "[H", function()
  require("gitsigns").nav_hunk("first")
end, { desc = "First Git Hunk" })

map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<cr>", { desc = "Stage Hunk" })
map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<cr>", { desc = "Reset Hunk" })
map("n", "<leader>ghS", "<cmd>Gitsigns stage_buffer<cr>", { desc = "Stage Buffer" })
map("n", "<leader>ghu", "<cmd>Gitsigns undo_stage_hunk<cr>", { desc = "Undo Stage Hunk" })
map("n", "<leader>ghR", "<cmd>Gitsigns reset_buffer<cr>", { desc = "Reset Buffer" })
map("n", "<leader>ghd", "<cmd>Gitsigns diffthis<cr>", { desc = "Diff This" })
map("n", "<leader>ghb", "<cmd>Gitsigns blame<cr>", { desc = "Blame Line" })
map("n", "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>", { desc = "Toggle Inline Git Blame" })
map({ "n", "v" }, "<leader>gp", "<cmd>Gitsigns preview_hunk_inline<cr>", { desc = "Git Preview Hunk Diff" })

map({ "n", "v" }, "<leader>gn", LazyVim.pick("git_log_line"), { desc = "Git Line Log" })
map({ "n", "v" }, "<leader>gs", LazyVim.pick("git_status"), { desc = "Git Status" })
map({ "n", "v" }, "<leader>gC", LazyVim.pick("git_log_file"), { desc = "Git Buffer Commit Log" })

-- Diffview.
map("n", "<leader>DO", "<cmd>DiffviewOpen<cr>", { desc = "Open Diffview" })
map("n", "<leader>DD", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" })
map("n", "<leader>gdh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File History Current" })
map("v", "<leader>gdh", ":'<,'>DiffviewFileHistory<cr>", { desc = "File History Selection" })
map("n", "<leader>gdH", "<cmd>DiffviewFileHistory<cr>", { desc = "File History All" })
map("n", "<leader>gdm", "<cmd>DiffviewOpen HEAD<cr>", { desc = "Diff Uncommitted Changes" })
map("n", "<leader>gdM", "<cmd>DiffviewOpen HEAD~1<cr>", { desc = "Diff Last Commit" })
map("n", "<leader>gdb", function()
  vim.ui.input({ prompt = "Compare branch: " }, function(branch)
    if branch and branch ~= "" then
      vim.cmd("DiffviewOpen " .. branch)
    end
  end)
end, { desc = "Diff With Branch" })
map("n", "<leader>gdd", function()
  local base_candidates = { "origin/main", "origin/master", "main", "master" }
  local base_branch
  for _, branch in ipairs(base_candidates) do
    vim.fn.system("git rev-parse --verify " .. branch .. " 2>/dev/null")
    if vim.v.shell_error == 0 then
      base_branch = branch
      break
    end
  end
  if not base_branch then
    vim.notify("Could not find base branch", vim.log.levels.WARN)
    return
  end
  vim.cmd("DiffviewOpen " .. base_branch .. "...")
  vim.notify("Comparing against " .. base_branch, vim.log.levels.INFO)
end, { desc = "Diff From Base Branch" })
map("n", "<leader>gdf", function()
  vim.ui.input({ prompt = "Diff current file with: ", completion = "file" }, function(file)
    if file and file ~= "" then
      vim.cmd("vertical diffsplit " .. vim.fn.fnameescape(file))
    end
  end)
end, { desc = "Diff Current File" })

-- Persistent breakpoints.
map({ "n", "v" }, "<leader>dd", function()
  require("persistent-breakpoints.api").toggle_breakpoint()
end, { desc = "Toggle Breakpoint" })
map({ "n", "v" }, "<leader>dD", function()
  require("persistent-breakpoints.api").set_conditional_breakpoint()
end, { desc = "Breakpoint Condition" })
map({ "n", "v" }, "<leader>dX", function()
  require("persistent-breakpoints.api").clear_all_breakpoints()
end, { desc = "Clear All Breakpoints" })
map({ "n", "v" }, "<leader>df", function()
  require("persistent-breakpoints.api").set_log_point()
end, { desc = "Set Log Point" })

-- Tabs and buffers.
map({ "n", "v" }, "<leader>wn", "<cmd>tabnew<cr>", { desc = "Create New Tab" })
map({ "n", "v" }, "<leader>wc", "<cmd>tabclose<cr>", { desc = "Close Current Tab" })
map("n", "<leader>bn", "<cmd>enew<cr>", { desc = "New Buffer" })
map("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
map("n", "<leader>bD", function()
  Snacks.bufdelete({ force = true })
end, { desc = "Delete Buffer Force" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

map("n", "<leader>uw", "<cmd>set wrap!<cr>", { desc = "Toggle Word Wrap" })
map("n", "<leader>n", function()
  Snacks.notifier.show_history()
end, { desc = "Notification History" })
map("n", "<leader>un", function()
  Snacks.notifier.hide()
end, { desc = "Dismiss All Notifications" })
map("n", "<leader>nm", "<cmd>messages<cr>", { desc = "Vim Messages" })
map("n", "<leader>fc", function()
  local path = vim.fn.expand("%:.")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy Relative File Path" })

local function smart_cancel()
  local mode = vim.fn.mode()
  if mode == "o" or mode == "ov" then
    return "<Esc>"
  end
  if mode == "i" or mode == "ic" or mode == "s" or mode == "c" then
    return "<C-c>"
  end
  return "<Esc>"
end

map({ "n", "v", "o", "i" }, "<C-c>", smart_cancel, {
  expr = true,
  silent = true,
  desc = "Smart Cancel",
})

vim.api.nvim_create_user_command("ReloadKeymaps", "luafile ~/.config/nvim/lua/config/keymaps.lua", {})
vim.api.nvim_create_user_command("ReloadOptions", "luafile ~/.config/nvim/lua/config/options.lua", {})

-- Remove LazyVim defaults that conflict with local habits.
del("n", "<leader>l")
