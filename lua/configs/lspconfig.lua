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

-- read :h vim.lsp.config for changing options of lsp servers 
