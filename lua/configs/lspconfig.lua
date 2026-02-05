require("nvchad.configs.lspconfig").defaults()

-- Helper function to add build flags for gopls
local function add_build_flags()
  local mappings = {
    -- Edit these to configure specific build tags if the project matches the following dir pattern
    -- { pattern = "test", tags = "some_tag" },
  }
  local tag_string = ""
  local cwd = vim.loop.cwd()

  for _, mapping in pairs(mappings) do
    if cwd:match(mapping.pattern) then
      tag_string = tag_string .. mapping.tags .. " "
    end
  end
  if tag_string == "" then
    return {}
  end
  tag_string = "-tags=" .. tag_string

  return {
    buildFlags = { tag_string },
  }
end

-- Custom LSP server configurations
local lsp_configs = {
  gopls = {
    settings = {
      gopls = vim.tbl_deep_extend("force", add_build_flags(), {
        -- Allow gopls to analyze dependencies
        directoryFilters = {
          "-**/node_modules",
          "+**/pkg/mod", -- Enable Go modules cache
        },
        -- Enable analysis of dependencies
        analyses = {
          unusedparams = true,
          shadow = true,
        },
        staticcheck = true,
        -- Better dependency analysis
        experimentalWorkspaceModule = true,
        allowImplicitNetworkAccess = true,
        -- Deeper analysis
        codelenses = {
          gc_details = false,
          generate = true,
          regenerate_cgo = true,
          test = true,
          tidy = true,
          upgrade_dependency = true,
          vendor = true,
        },
        hints = {
          assignVariableTypes = false,
          compositeLiteralFields = false,
          compositeLiteralTypes = false,
          constantValues = false,
          functionTypeParameters = false,
          parameterNames = false,
          rangeVariableTypes = false,
        },
      }),
    },
  },
}

-- Setup mason-lspconfig to automatically configure all installed servers
require("mason-lspconfig").setup({
  automatic_installation = true,
  handlers = {
    -- Default handler for all servers
    function(server_name)
      local config = lsp_configs[server_name] or {}
      vim.lsp.enable(server_name, config)
    end,
  },
})

-- Setup LSP keybindings with Telescope integration (LazyVim-style)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Helper function for buffer-local keymaps
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "LSP: " .. desc })
    end

    -- LSP Navigation keybindings using FzfLua
    map("n", "gd", "<cmd>FzfLua lsp_definitions<cr>", "Goto Definition")
    map("n", "gr", "<cmd>FzfLua lsp_references<cr>", "Goto References")
    map("n", "gI", "<cmd>FzfLua lsp_implementations<cr>", "Goto Implementation")
    map("n", "gy", "<cmd>FzfLua lsp_typedefs<cr>", "Goto Type Definition")
    map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")

    -- Symbols
    map("n", "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", "Document Symbols")
    map("n", "<leader>sS", "<cmd>FzfLua lsp_workspace_symbols<cr>", "Workspace Symbols")

    -- Code actions
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")

    -- Documentation
    map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
    map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
    -- map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")

    -- Diagnostics
    map("n", "<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
    map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
    map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
  end,
})

-- read :h vim.lsp.config for changing options of lsp servers 
