-- Git worktree management via afonsofrancof/worktrees.nvim.
-- Replaces the previous custom polarmutex/git-worktree.nvim setup (preserved
-- on branch custom-git-worktree-plugin). UI is native vim.ui.select/input,
-- which routes through Snacks (no telescope).
--
-- Switch uses a thin wrapper (switch_tabbed) instead of :WorktreeSwitch so each
-- worktree gets its own tab: jump to the existing tab if open, else open a new
-- tab. Tabs are pinned with tab-local cwd (tcd) so the plugin's global `cd`
-- does not leak between worktree tabs (which would make new files resolve
-- against the wrong worktree).

-- Find a tabpage already associated with this worktree path, if any.
local function tab_for_worktree(path)
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local ok, p = pcall(vim.api.nvim_tabpage_get_var, tab, "worktree_path")
    if ok and p == path then
      return tab
    end
  end
end

-- Pin the current tab to a worktree: tag it and set tab-local cwd.
local function pin_tab(path)
  pcall(vim.api.nvim_tabpage_set_var, 0, "worktree_path", path)
  pcall(function()
    vim.cmd.tcd(vim.fn.fnameescape(path))
  end)
end

local function switch_tabbed()
  local git = require("worktrees.git")
  local worktrees = git.get_worktrees()
  if not worktrees or vim.tbl_count(worktrees) == 0 then
    vim.notify("No worktrees found", vim.log.levels.WARN)
    return
  end

  local current = vim.fs.normalize(git.get_worktree_root() or "")
  local items = {}
  for _, wt in pairs(worktrees) do
    if wt.path ~= current then
      table.insert(items, { path = wt.path, name = wt.name or vim.fn.fnamemodify(wt.path, ":t") })
    end
  end
  if #items == 0 then
    vim.notify("No other worktrees to switch to", vim.log.levels.WARN)
    return
  end

  vim.ui.select(items, {
    prompt = "Switch worktree:",
    format_item = function(it)
      return it.name .. "  (" .. it.path .. ")"
    end,
  }, function(choice)
    if not choice then
      return
    end

    -- Jump to an existing tab for this worktree (its tcd restores the cwd).
    local existing = tab_for_worktree(choice.path)
    if existing then
      vim.api.nvim_set_current_tabpage(existing)
      return
    end

    -- Pin the current (source) tab to its worktree before leaving, so a later
    -- switch back finds it instead of spawning a duplicate.
    if current ~= "" then
      pin_tab(current)
    end

    -- Open the target in a new tab. switch_worktree does the global cd + opens
    -- the worktree view; pin_tab then makes the cwd tab-local.
    vim.cmd("tabnew")
    require("worktrees").utils.switch_worktree(choice.path, true)
    pin_tab(choice.path)
  end)
end

return {
  "afonsofrancof/worktrees.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>gwc", "<cmd>WorktreeCreate<cr>", desc = "Create Worktree" },
    { "<leader>gwl", switch_tabbed, desc = "Switch Worktree (tab)" },
    { "<leader>gwd", "<cmd>WorktreeDelete<cr>", desc = "Delete Worktree" },
  },
  opts = {
    -- Worktrees live in <repo-root>/.worktrees/. base_path is relative to the
    -- git common dir (<repo-root>/.git), which resolves to the main repo even
    -- when invoked from inside a linked worktree.
    base_path = "../.worktrees",
    -- Flatten branch names into folder names: benk/foo -> benk-foo.
    path_template = function(branch)
      return (branch:gsub("/", "-"))
    end,
  },
}
