local known_goos = {
  aix = true,
  android = true,
  darwin = true,
  dragonfly = true,
  freebsd = true,
  illumos = true,
  ios = true,
  js = true,
  linux = true,
  netbsd = true,
  openbsd = true,
  plan9 = true,
  solaris = true,
  wasip1 = true,
  wasip2 = true,
  windows = true,
  zos = true,
}

local known_goarch = {
  ["386"] = true,
  amd64 = true,
  arm = true,
  arm64 = true,
  loong64 = true,
  mips = true,
  mips64 = true,
  mips64le = true,
  mipsle = true,
  ppc64 = true,
  ppc64le = true,
  riscv64 = true,
  s390x = true,
  wasm = true,
}

local excluded_tags = {
  ignore = true,
  cgo = true,
}

local function is_custom_tag(tag)
  if known_goos[tag] or known_goarch[tag] or excluded_tags[tag] then
    return false
  end
  return not tag:match("^go%d")
end

local function extract_tags_from_lines(lines)
  local tags = {}
  for _, line in ipairs(lines) do
    if line:match("^package%s+") then
      break
    end

    local expr = line:match("^//go:build%s+(.+)$")
    if expr then
      for tag in expr:gmatch("[%w_]+") do
        if is_custom_tag(tag) then
          tags[tag] = true
        end
      end
    end

    local build_expr = line:match("^//%s+%+build%s+(.+)$")
    if build_expr then
      for tag in build_expr:gmatch("[%w_]+") do
        if is_custom_tag(tag) then
          tags[tag] = true
        end
      end
    end
  end
  return tags
end

local function scan_go_build_tags()
  local cwd = vim.uv.cwd() or vim.loop.cwd()
  local files = vim.fn.systemlist("git ls-files '*.go' 2>/dev/null")

  if vim.v.shell_error ~= 0 or #files == 0 then
    files = {}
    for _, file in ipairs(vim.fn.glob(cwd .. "/**/*.go", false, true)) do
      files[#files + 1] = file:sub(#cwd + 2)
    end
  end

  local all_tags = {}

  for _, rel_path in ipairs(files) do
    local abs_path = cwd .. "/" .. rel_path
    local ok, lines = pcall(function()
      local f = io.open(abs_path, "r")
      if not f then
        return {}
      end

      local result = {}
      for i = 1, 20 do
        local line = f:read("*l")
        if not line then
          break
        end
        result[i] = line
      end
      f:close()
      return result
    end)

    if ok and lines and #lines > 0 then
      for tag in pairs(extract_tags_from_lines(lines)) do
        all_tags[tag] = true
      end
    end
  end

  local result = vim.tbl_keys(all_tags)
  table.sort(result)
  return result
end

local function apply_gopls_build_tags(tags)
  if #tags == 0 then
    return
  end

  local flag = "-tags=" .. table.concat(tags, ",")
  for _, client in ipairs(vim.lsp.get_clients({ name = "gopls" })) do
    client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
      gopls = {
        buildFlags = { flag },
      },
    })
    client:notify("workspace/didChangeConfiguration", { settings = client.settings })
  end
end

local gopls_tags_applied = false

local function refresh_gopls_tags(opts)
  opts = opts or {}
  if gopls_tags_applied and not opts.force then
    return
  end

  local tags = scan_go_build_tags()
  gopls_tags_applied = true

  if #tags > 0 then
    apply_gopls_build_tags(tags)
    if not opts.silent then
      vim.notify("gopls: auto-detected build tags: " .. table.concat(tags, ", "), vim.log.levels.INFO)
    end
  end
end

local function is_large_file(bufnr)
  local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
  return ok and stats and stats.size > 1024 * 1024
end

-- Parse octo review buffer URI to extract the real file path
-- Format: octo://<owner>/<repo>/review/<id>/file/<SIDE>/<path>
-- Only bridges RIGHT side (PR head), returns nil for LEFT or non-review URIs
local function octo_uri_to_real_path(bufname)
  local side, path = bufname:match("^octo://[^/]+/[^/]+/review/[^/]+/file/(%u+)/(.+)$")
  if not side or side ~= "RIGHT" or not path then
    return nil
  end
  local root = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })[1]
  if vim.v.shell_error ~= 0 or not root then
    return nil
  end
  return root .. "/" .. path
end

-- Bridge LSP hover request from octo buffer to real file
local function bridge_octo_hover()
  local bufname = vim.api.nvim_buf_get_name(0)
  local real_path = octo_uri_to_real_path(bufname)
  if not real_path then
    return false
  end

  local real_bufnr = vim.fn.bufadd(real_path)
  vim.fn.bufload(real_bufnr)

  -- Wait briefly for LSP to attach to real buffer
  vim.wait(2000, function()
    return #vim.lsp.get_clients({ bufnr = real_bufnr }) > 0
  end)

  local clients = vim.lsp.get_clients({ bufnr = real_bufnr })
  if #clients == 0 then
    vim.notify("No LSP client for: " .. real_path, vim.log.levels.WARN)
    return false
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local params = vim.lsp.util.make_text_document_params(real_bufnr)
  params.position = { line = row - 1, character = col }

  local handler = vim.lsp.handlers.hover
  for _, client in ipairs(clients) do
    client.request("textDocument/hover", params, function(err, result)
      if err or not result or not result.contents then
        return
      end
      local conf = {}
      conf.border = "rounded"
      conf.focusable = true
      conf.stylize_markdown = false
      local bufnr, winnr = vim.lsp.util.open_floating_preview(
        vim.lsp.util.convert_input_to_markdown_lines(result.contents, {}),
        "markdown",
        conf
      )
      if bufnr and winnr then
        vim.bo[bufnr].filetype = ""
        vim.bo[bufnr].syntax = "off"
        vim.wo[winnr].conceallevel = 0
        vim.wo[winnr].concealcursor = ""
        vim.wo[winnr].wrap = true
      end
    end, "sync")
    break
  end
  return true
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.inlay_hints = {
        enabled = false,
        exclude = { "vue" },
      }

      opts.servers = vim.tbl_deep_extend("force", opts.servers or {}, {
        golangci_lint_ls = {
          -- Mirror the nvim-lspconfig default command (v2 flags) with two additions:
          -- --fast-only: cuts run time from ~2.7s to ~1.1s by skipping slow linters
          --   (unused, staticcheck, gosec). Fast linters (govet, errcheck, etc) still run.
          -- --allow-parallel-runners: skips the /tmp/golangci-lint.lock file acquisition.
          --   Without this, a 5s lock wait triggers when the LSP run overlaps with a
          --   terminal golangci-lint run or another nvim instance, causing the
          --   "parallel golangci-lint is running" diagnostic error on line 1.
          init_options = {
            command = {
              "golangci-lint",
              "run",
              "--output.text.path=",
              "--output.tab.path=",
              "--output.html.path=",
              "--output.checkstyle.path=",
              "--output.junit-xml.path=",
              "--output.teamcity.path=",
              "--output.sarif.path=",
              "--fast-only",
              "--allow-parallel-runners",
              "--show-stats=false",
              "--output.json.path=stdout",
            },
          },
        },
        basedpyright = {
          settings = {
            basedpyright = {
              disableOrganizeImports = true,
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
              },
            },
          },
        },
        ruff = {
          on_attach = function(client)
            client.server_capabilities.hoverProvider = false
          end,
        },
        gopls = {
          settings = {
            gopls = {
              directoryFilters = {
                "-**/node_modules",
                "+**/pkg/mod",
              },
              analyses = {
                unusedparams = true,
                shadow = true,
              },
              staticcheck = true,
              experimentalWorkspaceModule = false,
              allowImplicitNetworkAccess = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              -- hints are disabled at the nvim level (inlay_hints.enabled=false)
              -- so do not configure them here to avoid server-side computation
            },
          },
        },
        clangd = {
          cmd = {
            vim.fn.stdpath("data") .. "/mason/bin/clangd",
            "--background-index",
            "--clang-tidy",
            "--completion-style=detailed",
            "--header-insertion=never",
            "--compile-commands-dir=build/Debug",
          },
          init_options = {
            clangdFileStatus = true,
          },
        },
      })
    end,
    init = function()
      vim.api.nvim_create_user_command("GoplsRefreshTags", function()
        refresh_gopls_tags({ force = true })
      end, { desc = "Re-scan workspace for Go build tags and apply to gopls" })

      vim.api.nvim_create_user_command("GoplsBuildTags", function()
        local clients = vim.lsp.get_clients({ name = "gopls" })
        if #clients == 0 then
          vim.notify("gopls is not running", vim.log.levels.WARN)
          return
        end
        for _, client in ipairs(clients) do
          local flags = (client.settings.gopls or {}).buildFlags or {}
          if #flags == 0 then
            vim.notify("gopls: no build tags active", vim.log.levels.INFO)
          else
            vim.notify("gopls build flags: " .. table.concat(flags, " "), vim.log.levels.INFO)
          end
        end
      end, { desc = "Show currently active gopls build tags" })

      -- Disable document_color globally. It is enabled by default in nvim 0.11+
      -- and sends textDocument/didChange to every LSP on every keystroke with
      -- zero debounce (neovim issue #39785). This causes high CPU on gopls and
      -- golangci_lint_ls for every character typed.
      if vim.lsp.document_color then
        vim.lsp.document_color.enable(false)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local bufname = vim.api.nvim_buf_get_name(bufnr)

          -- Detach LSP from octo:// buffers (gopls rejects non-file URIs)
          if bufname:match("^octo://") then
            vim.lsp.buf_detach_client(bufnr, args.data.client_id)
            return
          end

          if is_large_file(bufnr) then
            vim.lsp.buf_detach_client(bufnr, args.data.client_id)
            return
          end

          if client and client.name == "gopls" then
            vim.schedule(function()
              refresh_gopls_tags()
            end)
          end

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "LSP: " .. desc })
          end

          map("n", "gd", LazyVim.pick("lsp_definitions"), "Goto Definition")
          map("n", "gr", LazyVim.pick("lsp_references"), "Goto References")
          map("n", "gI", LazyVim.pick("lsp_implementations"), "Goto Implementation")
          map("n", "gy", LazyVim.pick("lsp_type_definitions"), "Goto Type Definition")
          map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
          map("n", "<leader>ss", LazyVim.pick("lsp_document_symbols"), "Document Symbols")
          map("n", "<leader>sS", LazyVim.pick("lsp_workspace_symbols"), "Workspace Symbols")
          map({ "n", "v" }, "<leader>ca", function()
            require("actions-preview").code_actions()
          end, "Code Action")
          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
          map({ "n", "v" }, "<leader>cf", function()
            vim.lsp.buf.format({ bufnr = bufnr })
          end, "Format Buffer")
          map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
          map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
          map("n", "<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
          map("n", "<leader>uH", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, "Toggle Inlay Hints (Global)")
          map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
          map("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic")

          -- [[/]] are handled by Snacks.words via LazyVim's LSP keymaps
          -- (requires documentHighlight capability; falls back to treesitter motions)
        end,
      })

      vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
        if err or not result or not result.contents then
          return
        end

        config = config or {}
        config.border = "rounded"
        config.focusable = true
        config.stylize_markdown = false

        local bufnr, winnr = vim.lsp.util.open_floating_preview(
          vim.lsp.util.convert_input_to_markdown_lines(result.contents, {}),
          "markdown",
          config
        )

        if bufnr and winnr then
          vim.bo[bufnr].filetype = ""
          vim.bo[bufnr].syntax = "off"
          vim.wo[winnr].conceallevel = 0
          vim.wo[winnr].concealcursor = ""
          vim.wo[winnr].wrap = true
          vim.api.nvim_buf_call(bufnr, function()
            pcall(vim.treesitter.stop, bufnr)
          end)
        end

        return bufnr, winnr
      end

      -- Set up bridged LSP keymaps for octo review buffers
      vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "octo://*/review/*/file/RIGHT/*",
        callback = function(args)
          local bufnr = args.buf
          vim.keymap.set("n", "K", function()
            if not bridge_octo_hover() then
              vim.notify("No hover available (not a bridged octo buffer)", vim.log.levels.WARN)
            end
          end, { buffer = bufnr, desc = "LSP Hover (bridged to real file)" })
        end,
      })
    end,
  },
}
