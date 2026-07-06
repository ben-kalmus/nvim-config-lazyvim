return {
  "RRethy/vim-illuminate",
  event = "BufReadPost",
  opts = {
    delay = 200,
    providers = { "treesitter", "regex" },
    large_file_cutoff = 2000,
    filetypes_denylist = {
      "dirbuf",
      "dirvish",
      "fugitive",
      "NvimTree",
      "lazy",
      "mason",
      "DiffviewFiles",
      "DiffviewFileHistory",
    },
  },
  config = function(_, opts)
    require("illuminate").configure(opts)

    -- Set highlight to background color instead of underline
    vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = "#3b4261" })
    vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = "#3b4261" })
    vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = "#3b4261" })

    -- ]]/[[ reference jump handled by Snacks.words (LazyVim buffer-local map).
    -- illuminate's goto_next_reference is async-debounced and disabled on
    -- files over large_file_cutoff, so it was an unreliable no-op on big files.
  end,
}
