local function worktree_repo_root()
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return root
end

local function worktree_list()
  local lines = vim.fn.systemlist("git worktree list --porcelain")
  local worktrees = {}
  local current = {}
  for _, line in ipairs(lines) do
    local path = line:match("^worktree%s+(.+)$")
    local branch = line:match("^branch%s+refs/heads/(.+)$")
    local bare = line:match("^bare$")
    if path then
      if current.path then
        table.insert(worktrees, current)
      end
      current = { path = path }
    elseif branch then
      current.branch = branch
    elseif bare then
      current.bare = true
    elseif line == "" and current.path then
      table.insert(worktrees, current)
      current = {}
    end
  end
  if current.path then
    table.insert(worktrees, current)
  end
  return worktrees
end

return {
  "polarmutex/git-worktree.nvim",
  version = "^2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>gwl", desc = "List/Switch Worktree" },
    { "<leader>gwc", desc = "Create Worktree" },
    { "<leader>gwd", desc = "Delete Worktree" },
  },
  config = function()
    vim.g.git_worktree = {
      change_directory_command = "tcd",
      update_on_change = true,
      clearjumps_on_change = true,
      autopush = false,
    }
    local Hooks = require("git-worktree.hooks")
    Hooks.register(
      Hooks.type.SWITCH,
      Hooks.builtins.update_current_buffer_on_switch
    )

    -- Switch worktree via Snacks picker
    vim.keymap.set("n", "<leader>gwl", function()
      local worktrees = worktree_list()
      if #worktrees == 0 then
        vim.notify("No worktrees found", vim.log.levels.WARN)
        return
      end
      local items = {}
      for _, wt in ipairs(worktrees) do
        table.insert(items, {
          text = (wt.branch or "(detached)") .. "  " .. wt.path,
          path = wt.path,
          branch = wt.branch,
        })
      end
      Snacks.picker({
        title = "Git Worktrees",
        items = items,
        format = function(item)
          return { { item.text } }
        end,
        confirm = function(picker, item)
          picker:close()
          require("git-worktree").switch_worktree(item.path)
        end,
      })
    end, { desc = "List/Switch Worktree" })

    -- Create worktree — branch name drives the folder name (slashes → dashes)
    vim.keymap.set("n", "<leader>gwc", function()
      local root = worktree_repo_root()
      if not root then
        vim.notify("Not inside a git repo", vim.log.levels.ERROR)
        return
      end
      Snacks.input({ prompt = "Branch name: " }, function(branch)
        if not branch or branch == "" then
          return
        end
        local folder = branch:gsub("/", "-")
        local path = root .. "/.worktrees/" .. folder
        require("git-worktree").create_worktree(path, branch)
        vim.notify("Worktree created: " .. path .. " (" .. branch .. ")", vim.log.levels.INFO)
      end)
    end, { desc = "Create Worktree" })

    -- Delete worktree via Snacks picker (excludes main worktree)
    vim.keymap.set("n", "<leader>gwd", function()
      local root = worktree_repo_root()
      local worktrees = worktree_list()
      local items = {}
      for _, wt in ipairs(worktrees) do
        if wt.path ~= root then
          table.insert(items, {
            text = (wt.branch or "(detached)") .. "  " .. wt.path,
            path = wt.path,
            branch = wt.branch,
          })
        end
      end
      if #items == 0 then
        vim.notify("No non-main worktrees to delete", vim.log.levels.INFO)
        return
      end
      Snacks.picker({
        title = "Delete Worktree",
        items = items,
        format = function(item)
          return { { item.text } }
        end,
        confirm = function(picker, item)
          picker:close()
          require("git-worktree").delete_worktree(item.path)
          vim.notify("Deleted worktree: " .. item.path, vim.log.levels.INFO)
        end,
      })
    end, { desc = "Delete Worktree" })
  end,
}
