return {
    "epwalsh/obsidian.nvim",
    enabled = true,

    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    -- event = {
    --     "BufReadPre " .. vim.fn.expand "~" .. "/notes-vault/personal/*.md",
    --     "BufNewFile " .. vim.fn.expand "~" .. "/notes-vault/personal/*.md",
    -- },
    -- dependencies = {
    --     "nvim-lua/plenary.nvim",
    --     "nvim-telescope/telescope.nvim",
    -- },
    opts = {
        ui = {
            enable = false,
        },
        workspaces = {
            {
                name = "notes",
                path = "~/notes-vault",
            },
        },
        daily_notes = {
            folder = "daily", -- keep daily notes in a separate folder
            template = "notes/templates/daily.md",
        },
        templates = {
            subdir = "notes/templates",
        },
        completion = {
            -- Set to false to disable completion.
            nvim_cmp = true,
            -- Trigger completion at 2 chars.
            min_chars = 2,
        },
        -- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
        -- way then set 'mappings = {}'.
        mappings = {
            -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
            ["gf"] = {
                action = function()
                    return require("obsidian").util.gf_passthrough()
                end,
                opts = { noremap = false, expr = true, buffer = true },
            },
            -- Toggle check-boxes.
            ["<leader>ch"] = {
                action = function()
                    return require("obsidian").util.toggle_checkbox()
                end,
                opts = { buffer = true },
            },
            -- Smart action depending on context, either follow link or toggle checkbox.
            ["<cr>"] = {
                action = function()
                    return require("obsidian").util.smart_action()
                end,
                opts = { buffer = true, expr = true },
            },
        },
        -- Optional, customize how note IDs are generated given an optional title.
        ---@param title string|?
        ---@return string
        note_id_func = function(title)
            -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
            -- In this case a note with the title 'My new note' will be given an ID that looks
            -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
            local filename = ""
            if title ~= nil then
                -- If title is given, transform it into valid file name.
                filename = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
                -- check if file already exists in current directory
                if vim.fn.filereadable(vim.fn.expand("%:p:h") .. "/" .. filename .. ".md") == 1 then
                    -- If the file already exists, rename
                    filename = tostring(os.time()) .. "-" .. filename
                end
            else
                -- If title is nil, just add 4 random uppercase letters to the suffix.
                for _ = 1, 4 do
                    filename = tostring(os.time()) .. "-" .. string.char(math.random(65, 90))
                end
            end
            return filename
        end,

        -- Optional, alternatively you can customize the frontmatter data.
        ---@return table
        note_frontmatter_func = function(note)
            -- Add the title of the note as an alias.
            if note.title then
                note:add_alias(note.title)
            end

            local out = { id = note.id, aliases = note.aliases, tags = note.tags }

            -- `note.metadata` contains any manually added fields in the frontmatter.
            -- So here we just make sure those fields are kept in the frontmatter.
            if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
                for k, v in pairs(note.metadata) do
                    out[k] = v
                end
            end

            return out
        end,

        -- Specify how to handle attachments.
        attachments = {
            -- The default folder to place images in via `:ObsidianPasteImg`.
            -- If this is a relative path it will be interpreted as relative to the vault root.
            -- You can always override this per image by passing a full path to the command instead of just a filename.
            img_folder = "assets/imgs", -- This is the default

            -- Optional, customize the default name or prefix when pasting images via `:ObsidianPasteImg`.
            ---@return string
            img_name_func = function()
                -- Prefix image names with timestamp.
                return string.format("%s-", os.time())
            end,

            -- A function that determines the text to insert in the note when pasting an image.
            -- It takes two arguments, the `obsidian.Client` and an `obsidian.Path` to the image file.
            -- This is the default implementation.
            ---@param client obsidian.Client
            ---@param path obsidian.Path the absolute path to the image file
            ---@return string
            img_text_func = function(client, path)
                path = client:vault_relative_path(path) or path
                return string.format("![%s](%s)", path.name, path)
            end,
        },
    },
}
