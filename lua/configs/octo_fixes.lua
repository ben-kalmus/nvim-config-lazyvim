-- octo.nvim local patches
-- =======================
--
-- Small fixes for octo bugs we hit, kept out of the plugin spec so the config
-- stays readable. Each patch is a verbatim copy of an octo function with one
-- guard added (marked `>>> PATCH <<<`). Pinned to octo commit
-- b9a73e167f851a98d8f29d62658d3640bb8a7314. On an octo upgrade, re-copy the
-- named functions and re-apply the PATCH blocks; delete a patch once its fix
-- ships upstream.
--
-- Call require("configs.octo_fixes").install() from octo's plugin config.

local M = {}

-- Patch 1: notification picker crashes on CI notifications
-- --------------------------------------------------------
-- octo/pickers/snacks/provider.lua M.notifications() loops over every
-- notification and does, for EACH one:
--     notification.subject.number = notification.subject.url:match("%d+$")
-- CheckSuite / CI (and Release, Discussion) notifications have a null
-- subject.url. JSON null decodes to vim.NIL (a userdata), so the `:match`
-- throws "attempt to index field 'url' (a userdata value)", killing the async
-- gh callback before the picker renders. Result: an empty list even when real
-- PR/issue notifications exist.
--
-- Fix: compute kind first and skip non issue/PR kinds (which have no number
-- anyway) BEFORE touching subject.url. See the PATCH marker in the loop.
--
-- Whole-function copy because the buggy line is inside octo's own async gh
-- callback, so there is no seam to wrap just that line.
local function install_notifications_fix()
  local ok, provider = pcall(require, "octo.pickers.snacks.provider")
  if not ok then
    return
  end

  local gh = require("octo.gh")
  local headers = require("octo.gh.headers")
  local utils = require("octo.utils")
  local octo_config = require("octo.config")
  local navigation = require("octo.navigation")

  local function fixed_notifications(o)
    o = o or {}
    local cfg = octo_config.values

    local endpoint = "/notifications"
    if o.repo then
      local owner, name = utils.split_repo(o.repo)
      endpoint = string.format("/repos/%s/%s/notifications", owner, name)
    end
    o.prompt_title = o.repo and string.format("%s Notifications", o.repo) or "Github Notifications"
    o.preview_title = ""
    o.results_title = ""

    gh.api.get({
      endpoint,
      paginate = true,
      F = { all = o.all, since = o.since },
      opts = {
        headers = { headers.diff },
        cb = gh.create_callback({
          success = function(output)
            local notifications = vim.json.decode(output)
            if #notifications == 0 then
              utils.info("There are no notifications")
              return
            end

            local safe_notifications = {}
            for _, notification in ipairs(notifications) do
              notification.kind = notification.subject.type:lower()
              if notification.kind == "pullrequest" then
                notification.kind = "pull_request"
              end
              -- >>> PATCH: skip kinds without an issue/PR number (CheckSuite,
              -- Release, Discussion...). Their subject.url is null; the original
              -- deref'd it below and crashed the callback. <<<
              if notification.kind == "issue" or notification.kind == "pull_request" then
                notification.subject.number = notification.subject.url:match("%d+$")
                notification.text =
                  string.format("#%d %s", notification.subject.number, notification.subject.title)
                notification.status = notification.unread and "unread" or "read"
                if notification.kind == "issue" then
                  notification.file =
                    utils.get_issue_uri(notification.subject.number, notification.repository.full_name)
                else
                  notification.file =
                    utils.get_pull_request_uri(notification.subject.number, notification.repository.full_name)
                end
                safe_notifications[#safe_notifications + 1] = notification
              end
            end

            local final_actions = {}
            local final_keys = {}
            local default_mode = { "n", "i" }

            local custom_actions_defined = {}
            if
              cfg.picker_config.snacks
              and cfg.picker_config.snacks.actions
              and cfg.picker_config.snacks.actions.notifications
            then
              for _, action_item in ipairs(cfg.picker_config.snacks.actions.notifications) do
                if action_item.name and action_item.fn then
                  final_actions[action_item.name] = action_item.fn
                  custom_actions_defined[action_item.name] = true
                  if action_item.lhs then
                    final_keys[action_item.lhs] = { action_item.name, mode = action_item.mode or default_mode }
                  end
                end
              end
            end

            if not custom_actions_defined["open_in_browser"] then
              final_actions["open_in_browser"] = function(_picker, item)
                navigation.open_in_browser(item.kind, item.repository.full_name, item.subject.number)
              end
            end
            if not final_keys[cfg.picker_config.mappings.open_in_browser.lhs] then
              final_keys[cfg.picker_config.mappings.open_in_browser.lhs] =
                { "open_in_browser", mode = default_mode }
            end

            if not custom_actions_defined["copy_url"] then
              final_actions["copy_url"] = function(_picker, item)
                utils.copy_url(item.subject.url or "")
              end
            end
            if not final_keys[cfg.picker_config.mappings.copy_url.lhs] then
              final_keys[cfg.picker_config.mappings.copy_url.lhs] = { "copy_url", mode = default_mode }
            end

            if not custom_actions_defined["copy_sha"] then
              final_actions["copy_sha"] = function(_picker, item)
                if item.kind == "pull_request" then
                  utils.info("Fetching PR details for SHA...")
                  local owner, repo = item.repository.full_name:match("([^/]+)/(.+)")
                  gh.api.get({
                    "/repos/{owner}/{repo}/pulls/{pull_number}",
                    format = { owner = owner, repo = repo, pull_number = item.subject.number },
                    opts = {
                      cb = gh.create_callback({
                        success = function(pr_output)
                          local pr_data = vim.json.decode(pr_output)
                          utils.copy_sha(pr_data.head.sha)
                        end,
                      }),
                    },
                  })
                else
                  utils.info("Copy SHA not available for this notification type")
                end
              end
            end
            if not final_keys[cfg.picker_config.mappings.copy_sha.lhs] then
              final_keys[cfg.picker_config.mappings.copy_sha.lhs] = { "copy_sha", mode = default_mode }
            end

            if not custom_actions_defined["mark_notification_read"] then
              final_actions["mark_notification_read"] = function(picker, item)
                gh.api.patch({
                  "/notifications/threads/{id}",
                  format = { id = item.id },
                  opts = {
                    headers = { headers.diff },
                    cb = gh.create_callback({ success = function() end }),
                  },
                })
                picker:close()
                fixed_notifications(o)
              end
            end
            if
              cfg.mappings.notification
              and cfg.mappings.notification.read
              and not final_keys[cfg.mappings.notification.read.lhs]
            then
              final_keys[cfg.mappings.notification.read.lhs] =
                { "mark_notification_read", mode = default_mode }
            end

            Snacks.picker.pick({
              title = o.preview_title or "Notifications",
              items = safe_notifications,
              format = function(item, _)
                local ret = {}
                ret[#ret + 1] = utils.icons.notification[item.kind][item.status]
                ret[#ret + 1] = { string.format("#%d", item.subject.number), "Comment" }
                ret[#ret + 1] = { " " }
                ret[#ret + 1] = { item.repository.full_name, "Function" }
                ret[#ret + 1] = { " " }
                ret[#ret + 1] = { item.subject.title, "Normal" }
                return ret
              end,
              win = { input = { keys = final_keys } },
              actions = final_actions,
            })
          end,
        }),
      },
    })
  end

  -- Wire the patched fn into every reference the dispatch may use.
  -- picker.setup() copies provider.picker[k] into the octo.picker dispatch
  -- table by value, so patching only provider.notifications is not enough; the
  -- call site would still hold the original. Patch all three.
  provider.notifications = fixed_notifications
  if type(provider.picker) == "table" then
    provider.picker.notifications = fixed_notifications
  end
  local picker_ok, octo_picker = pcall(require, "octo.picker")
  if picker_ok and type(octo_picker) == "table" then
    octo_picker.notifications = fixed_notifications
  end
end

-- Patch 2: "Invalid buffer id" when a picker preview is scrolled away
-- ------------------------------------------------------------------
-- octo/init.lua M.load_buffer() fetches the issue/PR via async GraphQL, then in
-- the callback does nvim_buf_call(bufnr, ...). When the buffer is a snacks
-- picker preview and you move to another item before the fetch returns, the
-- preview buffer is wiped, so nvim_buf_call throws "Invalid buffer id: N".
--
-- Fix: bail if the target buffer is no longer valid. See the PATCH marker.
-- Verbatim copy of M.load_buffer otherwise. autocmds.lua calls
-- require("octo").load_buffer at call time, so reassigning the field is enough.
local function install_load_buffer_guard()
  local ok, octo = pcall(require, "octo")
  if not ok then
    return
  end
  local uri = require("octo.uri")
  local utils = require("octo.utils")

  octo.load_buffer = function(opts)
    opts = opts or {}
    local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local bufname = vim.fn.bufname(bufnr)
    local buffer_info = uri.parse(bufname)
    if buffer_info == nil then
      utils.print_err("Cannot parse buffer name: " .. bufname)
      return
    end
    local repo, kind, id, hostname = buffer_info.repo, buffer_info.kind, buffer_info.id, buffer_info.hostname

    octo.load(repo, kind, id, hostname, function(obj)
      -- >>> PATCH: the fetch is async; the buffer may have been wiped meanwhile
      -- (e.g. scrolled off a picker preview). Guard nvim_buf_call. <<<
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      vim.api.nvim_buf_call(bufnr, function()
        octo.create_buffer(kind, obj, repo, false, hostname)

        local lines = vim.api.nvim_buf_line_count(bufnr)
        local new_cursor_pos = {
          math.min(cursor_pos[1], lines),
          math.max(0, cursor_pos[2] - 1),
        }
        vim.api.nvim_win_set_cursor(0, new_cursor_pos)

        if opts.verbose then
          utils.info(string.format("Loaded %s/%s/%d", repo, kind, id))
        end
      end)
    end)
  end
end

function M.install()
  install_notifications_fix()
  install_load_buffer_guard()
end

return M
