local cmp = require("cmp")
return {
    "hrsh7th/nvim-cmp",
    enabled = false,
    opts = {
        completion = {
            completeopt = "menu,menuone,noselect,noinsert,popup",
        },
        preselect = cmp.PreselectMode.None,
    },
}
