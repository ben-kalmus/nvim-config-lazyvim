return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  event = "VeryLazy",
  config = function()
    -- Setup textobjects
    require("nvim-treesitter-textobjects").setup({
      move = {
        enable = true,
        set_jumps = true,
      },
      select = {
        enable = true,
        lookahead = true,
      },
      swap = {
        enable = true,
      },
    })

    -- Define movement keymaps
    local moves = {
      goto_next_start = {
        ["]f"] = "@function.outer",
        ["]c"] = "@class.outer",
        ["]a"] = "@parameter.inner",
        ["]o"] = "@loop.outer",           -- loops (for/while)
        ["]s"] = "@conditional.outer",    -- if/switch statements
        ["]m"] = "@call.outer",           -- method/function calls
        ["]z"] = "@fold",                 -- folds
      },
      goto_next_end = {
        ["]F"] = "@function.outer",
        ["]C"] = "@class.outer",
        ["]A"] = "@parameter.inner",
        ["]O"] = "@loop.outer",
        ["]S"] = "@conditional.outer",
        ["]M"] = "@call.outer",
      },
      goto_previous_start = {
        ["[f"] = "@function.outer",
        ["[c"] = "@class.outer",
        ["[a"] = "@parameter.inner",
        ["[o"] = "@loop.outer",
        ["[s"] = "@conditional.outer",
        ["[m"] = "@call.outer",
        ["[z"] = "@fold",
      },
      goto_previous_end = {
        ["[F"] = "@function.outer",
        ["[C"] = "@class.outer",
        ["[A"] = "@parameter.inner",
        ["[O"] = "@loop.outer",
        ["[S"] = "@conditional.outer",
        ["[M"] = "@call.outer",
      },
    }

    -- Define select keymaps
    local selects = {
      -- Functions and classes
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",

      -- Parameters and arguments
      ["aa"] = "@parameter.outer",
      ["ia"] = "@parameter.inner",

      -- Conditionals (if/switch)
      ["ai"] = "@conditional.outer",
      ["ii"] = "@conditional.inner",

      -- Loops (for/while)
      ["al"] = "@loop.outer",
      ["il"] = "@loop.inner",

      -- Blocks
      ["ab"] = "@block.outer",
      ["ib"] = "@block.inner",

      -- Calls (function/method calls)
      ["am"] = "@call.outer",
      ["im"] = "@call.inner",

      -- Comments
      ["a/"] = "@comment.outer",
    }

    -- Function to attach keymaps to buffer
    local function attach(buf)
      -- Create movement keymaps
      for method, keymaps in pairs(moves) do
        for key, query in pairs(keymaps) do
          local desc = key:sub(1, 1) == "]" and "Next" or "Prev"
          desc = desc .. " " .. query:gsub("@", ""):gsub("%..*", "")
          vim.keymap.set({ "n", "x", "o" }, key, function()
            require("nvim-treesitter-textobjects.move")[method](query)
          end, { buffer = buf, desc = desc, silent = true })
        end
      end

      -- Create select keymaps
      for key, query in pairs(selects) do
        vim.keymap.set({ "x", "o" }, key, function()
          require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
        end, { buffer = buf, desc = "Select " .. query, silent = true })
      end

      -- Create swap keymaps
      vim.keymap.set("n", "<leader>a", function()
        require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
      end, { buffer = buf, desc = "Swap next parameter", silent = true })

      vim.keymap.set("n", "<leader>A", function()
        require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
      end, { buffer = buf, desc = "Swap previous parameter", silent = true })
    end

    -- Attach to all FileType events
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_textobjects_keymaps", { clear = true }),
      callback = function(ev)
        attach(ev.buf)
      end,
    })

    -- Attach to existing buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) then
        attach(buf)
      end
    end
  end,
}
