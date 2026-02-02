-- source: https://github.com/daic0r/dap-helper.nvim
-- This dependency  provides convenience functions for:
--  - save and restore breakpoints across sessions!
--  - modify CLI args to debugee
return {
    "Weissle/persistent-breakpoints.nvim",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "mfussenegger/nvim-dap",
    },
    config = function()
        require("persistent-breakpoints").setup({
            load_breakpoints_event = { "BufReadPost" },
            always_reload = true,
        })
    end,
}
