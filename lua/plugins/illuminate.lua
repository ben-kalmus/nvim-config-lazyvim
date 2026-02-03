return {
  "RRethy/vim-illuminate",
  event = "BufReadPost",
  opts = {
    delay = 100,
    providers = { "lsp", "treesitter", "regex" },
    large_file_cutoff = 2000,
    filetypes_denylist = {
      "dirbuf",
      "dirvish",
      "fugitive",
      "NvimTree",
      "lazy",
      "mason",
    },
  },
  config = function(_, opts)
    require("illuminate").configure(opts)

    -- Set highlight to background color instead of underline
    vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = "#3b4261" })
    vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = "#3b4261" })
    vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = "#3b4261" })

    -- Jump to next/previous reference
    vim.keymap.set("n", "]]", function()
      require("illuminate").goto_next_reference()
    end, { desc = "Next Reference" })

    vim.keymap.set("n", "[[", function()
      require("illuminate").goto_prev_reference()
    end, { desc = "Prev Reference" })
  end,
}
