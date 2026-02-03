return {
  "xTacobaco/cursor-agent.nvim",
  cmd = { "CursorAgent", "CursorAgentSelection", "CursorAgentBuffer" },
  keys = {
    { "<C-.>", "<cmd>CursorAgent<CR>", desc = "Cursor Agent: Toggle terminal", mode = { "n", "t" } },
    { "<leader>Ca", "<cmd>CursorAgent<CR>", desc = "Cursor Agent: Toggle terminal", mode = "n" },
    { "<leader>Ca", ":<C-u>CursorAgentSelection<CR>", desc = "Cursor Agent: Send selection", mode = "v" },
    { "<leader>CA", "<cmd>CursorAgentBuffer<CR>", desc = "Cursor Agent: Send buffer", mode = "n" },
  },
  opts = {
    cmd = "cursor-agent",  -- Cursor Agent CLI command
    args = {},             -- Additional CLI arguments
    use_stdin = true,      -- Send content via stdin
    multi_instance = false, -- Single instance mode
    timeout_ms = 60000,    -- 60 second timeout
    auto_scroll = true,    -- Auto-scroll terminal
  },
  config = function(_, opts)
    require("cursor-agent").setup(opts)
  end,
}
