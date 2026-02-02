local HOME = "/home/benkalmus" --vim.fn.expand("~")
return {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
        linters = {
            ["markdownlint-cli2"] = {
                -- Disable annoying rule for trailing whitespaces
                -- args = { "--disable", "MD009", "--" },
                args = { "--config", HOME .. "/.markdownlint-cli2.yaml", "--" },
                -- inside .yaml: 
                -- config:
                --   MD009: false
            },
        },
    },
}
