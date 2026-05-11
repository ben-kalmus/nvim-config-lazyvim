return {
  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },

  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "biome" } },
  },
}
