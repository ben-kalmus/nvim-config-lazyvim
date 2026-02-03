return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  keys = {
    -- Quick access
    { "<leader><leader>", "<cmd>FzfLua files<cr>", desc = "Find Files" },

    -- Search prefix (LazyVim style)
    { "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "Grep (search)" },
    { "<leader>sw", "<cmd>FzfLua grep_cword<cr>", desc = "Word (search)" },
    { "<leader>sW", "<cmd>FzfLua grep_cWORD<cr>", desc = "WORD (search)" },
    { "<leader>sv", "<cmd>FzfLua grep_visual<cr>", desc = "Visual selection (search)", mode = "v" },
    { "<leader>sb", "<cmd>FzfLua buffers<cr>", desc = "Buffers (search)" },
    { "<leader>sh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags (search)" },
    { "<leader>sr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files (search)" },
    { "<leader>sc", "<cmd>FzfLua commands<cr>", desc = "Commands (search)" },
    { "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps (search)" },
    { "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document symbols (search)" },
    { "<leader>sS", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Workspace symbols (search)" },

    -- Also keep some <leader>f mappings for compatibility
    { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find Files (FZF)" },
    { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep (FZF)" },
    { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent Files (FZF)" },
  },
  opts = {
    winopts = {
      height = 0.9,
      width = 0.9,
      preview = {
        layout = "vertical",
        vertical = "down:70%",
      },
    },
    files = {
      -- Support for !pattern inverse search
      -- Example: type "!test.go" to exclude test files
      prompt_title = "Files (use ! to exclude)",
      git_icons = true,
      file_icons = true,
      color_icons = true,
    },
    grep = {
      prompt_title = "Live Grep (use ! to exclude)",
      -- Supports inverse patterns like "search !test.go"
    },
  },
}
