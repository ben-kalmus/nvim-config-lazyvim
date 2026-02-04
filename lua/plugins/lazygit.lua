-- Standalone Lazygit integration (adapted from snacks.nvim)
-- Original: https://github.com/folke/snacks.nvim/blob/main/lua/snacks/lazygit.lua

local M = {}

local defaults = {
  configure = true,
  config = {
    os = { editPreset = "nvim-remote" },
    gui = {
      nerdFontsVersion = "3",
    },
  },
  theme_path = vim.fn.stdpath("cache") .. "/lazygit-theme.yml",
  theme = {
    [241]                      = { fg = "Special" },
    activeBorderColor          = { fg = "MatchParen", bold = true },
    cherryPickedCommitBgColor  = { fg = "Identifier" },
    cherryPickedCommitFgColor  = { fg = "Function" },
    defaultFgColor             = { fg = "Normal" },
    inactiveBorderColor        = { fg = "FloatBorder" },
    optionsTextColor           = { fg = "Function" },
    searchingActiveBorderColor = { fg = "MatchParen", bold = true },
    selectedLineBgColor        = { bg = "Visual" },
    unstagedChangesColor       = { fg = "DiagnosticError" },
  },
}

local dirty = true
local config_dir = nil

-- Re-create theme file on ColorScheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    dirty = true
  end,
})

local function env(opts)
  if not config_dir then
    local out = vim.fn.system({ "lazygit", "-cd" })
    local lines = vim.split(out, "\n", { plain = true })

    if vim.v.shell_error == 0 and #lines > 1 then
      config_dir = vim.split(lines[1], "\n", { plain = true })[1]

      local config_files = vim.tbl_filter(function(v)
        return v:match("%S")
      end, vim.split(vim.env.LG_CONFIG_FILE or "", ",", { plain = true }))

      if #config_files == 0 then
        local default_config = config_dir .. "/config.yml"
        if vim.loop.fs_stat(default_config) then
          config_files[1] = default_config
        end
      end

      if not vim.tbl_contains(config_files, opts.theme_path) then
        table.insert(config_files, opts.theme_path)
      end

      vim.env.LG_CONFIG_FILE = table.concat(config_files, ",")
    else
      vim.notify(
        "Failed to get lazygit config directory.\\nWill not apply lazygit config.\\n\\nError:\\n" .. vim.trim(out),
        vim.log.levels.ERROR,
        { title = "lazygit" }
      )
    end
  end
end

local function get_color(v)
  local color = {}
  for _, c in ipairs({ "fg", "bg" }) do
    if v[c] then
      local name = v[c]
      local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
      local hl_color = nil
      if c == "fg" then
        hl_color = hl and hl.fg or hl.foreground
      else
        hl_color = hl and hl.bg or hl.background
      end
      if hl_color then
        table.insert(color, string.format("#%06x", hl_color))
      end
    end
  end
  if v.bold then
    table.insert(color, "bold")
  end
  return color
end

local function update_config(opts)
  local theme = {}

  for k, v in pairs(opts.theme) do
    if type(k) == "number" then
      local color = get_color(v)
      pcall(io.write, ("\\27]4;%d;%s\\7"):format(k, color[1]))
    else
      theme[k] = get_color(v)
    end
  end

  local config = vim.tbl_deep_extend("force", { gui = { theme = theme } }, opts.config or {})

  local function yaml_val(val)
    if type(val) == "boolean" then
      return tostring(val)
    end
    return type(val) == "string" and not val:find("^\\\"'`") and ("%q"):format(val) or val
  end

  local function to_yaml(tbl, indent)
    indent = indent or 0
    local lines = {}
    for k, v in pairs(tbl) do
      table.insert(lines, string.rep(" ", indent) .. k .. (type(v) == "table" and ":" or ": " .. yaml_val(v)))
      if type(v) == "table" then
        local is_list = vim.islist and vim.islist(v) or vim.tbl_islist(v)
        if is_list then
          for _, item in ipairs(v) do
            table.insert(lines, string.rep(" ", indent + 2) .. "- " .. yaml_val(item))
          end
        else
          vim.list_extend(lines, to_yaml(v, indent + 2))
        end
      end
    end
    return lines
  end

  vim.fn.writefile(to_yaml(config), opts.theme_path)
  dirty = false
end

-- Opens lazygit in a floating terminal
function M.open(opts)
  opts = vim.tbl_deep_extend("force", defaults, opts or {})

  local cmd = { "lazygit" }
  vim.list_extend(cmd, opts.args or {})

  if opts.configure then
    if dirty then
      update_config(opts)
    end
    env(opts)
  end

  -- Create a floating window
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)

  -- Create window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "single",
  })

  -- Set buffer options
  vim.bo[buf].bufhidden = "wipe"

  -- Start lazygit in terminal
  vim.fn.termopen(cmd, {
    on_exit = function()
      vim.schedule(function()
        -- Close window and buffer when lazygit exits
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end)
    end,
  })

  -- Enter terminal mode
  vim.cmd("startinsert")
end

-- Opens lazygit with the log view
function M.log(opts)
  opts = opts or {}
  opts.args = opts.args or { "log" }
  return M.open(opts)
end

-- Opens lazygit with the log of the current file
function M.log_file(opts)
  local file = vim.trim(vim.api.nvim_buf_get_name(0))
  opts = opts or {}
  opts.args = vim.list_extend(opts.args or {}, { "-f", file })
  opts.cwd = vim.fn.fnamemodify(file, ":h")
  return M.open(opts)
end

-- Setup keybindings
vim.keymap.set("n", "<leader>gg", function() M.open() end, { desc = "Lazygit" })
vim.keymap.set("n", "<leader>gl", function() M.log() end, { desc = "Lazygit Log" })
vim.keymap.set("n", "<leader>gf", function() M.log_file() end, { desc = "Lazygit Current File History" })

return {}
