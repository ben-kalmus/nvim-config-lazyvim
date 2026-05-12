local function worktree_repo_root()
  -- Use --git-common-dir so this works correctly from inside a worktree.
  -- --show-toplevel returns the worktree's own root, not the main repo root.
  local common_dir = vim.fn.systemlist("git rev-parse --git-common-dir")[1]
  if vim.v.shell_error ~= 0 or not common_dir then
    return nil
  end
  -- common_dir is either ".git" (relative, when in main repo) or an absolute path
  if not common_dir:match("^/") then
    common_dir = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    if vim.v.shell_error ~= 0 then
      return nil
    end
    return common_dir
  end
  -- strip trailing /.git
  return common_dir:gsub("/%.git$", "")
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

-- List branches that are NOT currently checked out by any worktree.
-- Returns items: { branch, is_remote, display }
-- Local branches first, then remote-only branches.
local function list_available_branches()
  local in_use = {}
  for _, wt in ipairs(worktree_list()) do
    if wt.branch then
      in_use[wt.branch] = true
    end
  end

  local locals = vim.fn.systemlist({ "git", "branch", "--format=%(refname:short)" })
  if vim.v.shell_error ~= 0 then
    return {}
  end
  local local_set = {}
  local items = {}
  for _, b in ipairs(locals) do
    if b ~= "" and not in_use[b] then
      local_set[b] = true
      table.insert(items, { branch = b, is_remote = false, display = "  " .. b .. "  [local]", text = b })
    end
  end

  local remotes = vim.fn.systemlist({ "git", "branch", "-r", "--format=%(refname:short)" })
  if vim.v.shell_error == 0 then
    for _, b in ipairs(remotes) do
      -- skip pointers like "origin/HEAD"
      if b ~= "" and not b:match("/HEAD$") then
        -- strip first path segment (remote name) to get logical local name
        local logical = b:gsub("^[^/]+/", "")
        if not local_set[logical] then
          table.insert(items, { branch = b, is_remote = true, display = "  " .. b .. "  [remote]", text = b })
        end
      end
    end
  end

  return items
end

return {
  "polarmutex/git-worktree.nvim",
  version = "^2",
  dependencies = { "nvim-lua/plenary.nvim" },
  -- Set config before the plugin module is first required so that config.lua
  -- picks it up when it evaluates vim.g.git_worktree at module load time.
  init = function()
    vim.g.git_worktree = {
      change_directory_command = "cd",
      update_on_change = true,
      clearjumps_on_change = true,
      autopush = false,
    }
  end,
  keys = {
    { "<leader>gwl", desc = "List/Switch Worktree" },
    { "<leader>gwc", desc = "Create Worktree From Branch" },
    { "<leader>gwn", desc = "Create Worktree With New Branch" },
    { "<leader>gwd", desc = "Delete Worktree" },
  },
  config = function()
    local Hooks = require("git-worktree.hooks")
    Hooks.register(Hooks.type.SWITCH, Hooks.builtins.update_current_buffer_on_switch)
    -- Fires after the async create job actually completes (worktree.lua:144).
    -- Replaces the old fire-immediately notification that lied about success.
    Hooks.register(Hooks.type.CREATE, function(path, branch)
      vim.notify("Worktree created: " .. path .. " (" .. (branch or "?") .. ")", vim.log.levels.INFO)
    end)

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

    -- Create worktree from EXISTING branch (picker, no typing).
    -- Local branches: use plugin's create_worktree (runs `git worktree add <path> <branch>`).
    -- Remote-only branches: bypass plugin to avoid its `local/` prefix; run
    -- `git worktree add --track -b <local_name> <path> <remote_ref>` directly,
    -- then call switch_worktree to fire the SWITCH hook.
    vim.keymap.set("n", "<leader>gwc", function()
      local root = worktree_repo_root()
      if not root then
        vim.notify("Not inside a git repo", vim.log.levels.ERROR)
        return
      end
      local items = list_available_branches()
      if #items == 0 then
        vim.notify("No branches available (all checked out by worktrees)", vim.log.levels.WARN)
        return
      end
      Snacks.picker({
        title = "Create Worktree From Branch",
        items = items,
        -- is_remote:desc puts locals (false→1) before remotes (true→0) regardless
        -- of filter input. Without this, the ~3000 remotes drown out the locals.
        sort = { fields = { "is_remote:desc", "score:desc", "#text", "idx" } },
        format = function(item)
          return { { item.display } }
        end,
        confirm = function(picker, item)
          picker:close()
          local logical_name = item.is_remote and item.branch:gsub("^[^/]+/", "") or item.branch
          local folder = logical_name:gsub("/", "-")
          local path = root .. "/.worktrees/" .. folder
          if vim.uv.fs_stat(path) then
            vim.notify("Worktree path already exists: " .. path, vim.log.levels.ERROR)
            return
          end
          -- Bypass the plugin's create_worktree for all cases: the plugin's
          -- remote-branch detection rewrites local branch names and its
          -- has_worktree check can produce false "already in use" errors.
          -- Run git directly for both local and remote branches.
          local cmd
          if item.is_remote then
            cmd = { "git", "worktree", "add", "--track", "-b", logical_name, path, item.branch }
          else
            cmd = { "git", "worktree", "add", path, item.branch }
          end
          local out = vim.fn.systemlist(cmd)
          if vim.v.shell_error ~= 0 then
            vim.notify("git worktree add failed:\n" .. table.concat(out, "\n"), vim.log.levels.ERROR)
            return
          end
          if item.is_remote then
            vim.notify("Worktree created: " .. path .. " (" .. logical_name .. " → " .. item.branch .. ")", vim.log.levels.INFO)
          else
            vim.notify("Worktree created: " .. path .. " (" .. item.branch .. ")", vim.log.levels.INFO)
          end
          vim.schedule(function()
            require("git-worktree").switch_worktree(path)
          end)
        end,
      })
    end, { desc = "Create Worktree From Branch" })

    -- Create worktree with a NEW branch off HEAD.
    -- Pre-fills with current branch (typically you'll change it).
    vim.keymap.set("n", "<leader>gwn", function()
      local root = worktree_repo_root()
      if not root then
        vim.notify("Not inside a git repo", vim.log.levels.ERROR)
        return
      end
      local current_branch = vim.fn.systemlist("git branch --show-current")[1] or ""
      Snacks.input({ prompt = "New branch name: ", default = current_branch }, function(branch)
        if not branch or branch == "" then
          return
        end
        -- Pre-flight: if branch already exists, redirect user to <leader>gwc.
        vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", "refs/heads/" .. branch })
        if vim.v.shell_error == 0 then
          vim.notify("Branch '" .. branch .. "' already exists. Use <leader>gwc to pick it.", vim.log.levels.ERROR)
          return
        end
        local folder = branch:gsub("/", "-")
        local path = root .. "/.worktrees/" .. folder
        if vim.uv.fs_stat(path) then
          vim.notify("Worktree path already exists: " .. path, vim.log.levels.ERROR)
          return
        end
        require("git-worktree").create_worktree(path, branch)
        vim.schedule(function()
          require("git-worktree").switch_worktree(path)
        end)
      end)
    end, { desc = "Create Worktree With New Branch" })

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
          -- Bypass the plugin: it runs the delete async, logs failures only
          -- to its own log file, and never propagates errors back to the
          -- caller. Run git directly so we can surface real errors.
          local function do_delete(force)
            local cmd = { "git", "worktree", "remove", item.path }
            if force then
              table.insert(cmd, "--force")
            end
            local out = vim.fn.systemlist(cmd)
            if vim.v.shell_error ~= 0 then
              return false, table.concat(out, "\n")
            end
            return true
          end

          local ok, err = do_delete(false)
          if ok then
            vim.notify("Deleted worktree: " .. item.path, vim.log.levels.INFO)
            return
          end

          vim.schedule(function()
            Snacks.input({
              prompt = "git worktree remove failed:\n" .. err .. "\nRetry with --force? (y/N): ",
            }, function(answer)
              if answer and answer:lower():sub(1, 1) == "y" then
                local ok2, err2 = do_delete(true)
                if ok2 then
                  vim.notify("Force-deleted worktree: " .. item.path, vim.log.levels.WARN)
                else
                  vim.notify("Force-delete failed:\n" .. err2, vim.log.levels.ERROR)
                end
              else
                vim.notify("Worktree not deleted: " .. item.path, vim.log.levels.INFO)
              end
            end)
          end)
        end,
      })
    end, { desc = "Delete Worktree" })
  end,
}
