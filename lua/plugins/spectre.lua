return {
  "nvim-pack/nvim-spectre",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("spectre").setup()
  end,
  keys = {
    { "<leader>sR", "<cmd>Spectre<cr>", desc = "Search and replace (project)" },
    -- { "<leader>sw", "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", desc = "Search current word (project)" },
    -- { "<leader>sw", "<cmd>lua require('spectre').open_visual()<cr>", mode = "v", desc = "Search selection (project)" },
  },
}
