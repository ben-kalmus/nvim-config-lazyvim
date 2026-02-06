-- Test argument presets for running tests with custom flags
-- Use <leader>ta to select a preset when running tests
-- Args must use = format (e.g., -provider=aws, not -provider aws)
local arg_presets = {
    ["Minimetis"] = {"-provider=aws", "-instance=local", "-domain=localhost", "-n=minimetis"},
    -- Add more presets here
}

local last_custom_args = nil

local function select_preset(callback)
    local choices = { "Custom (enter manually)" }

    if last_custom_args then
        table.insert(choices, "Last Used: " .. table.concat(last_custom_args, " "))
    end

    for name in pairs(arg_presets) do
        table.insert(choices, name)
    end

    vim.ui.select(choices, { prompt = "Select test args preset:" }, function(choice)
        if not choice then return end

        if choice == "Custom (enter manually)" then
            local default_str = last_custom_args and table.concat(last_custom_args, " ") or ""
            vim.ui.input({ prompt = "Test args: ", default = default_str }, function(input)
                if input and input ~= "" then
                    last_custom_args = vim.split(input, " ")
                    callback(last_custom_args)
                end
            end)
        elseif choice:match("^Last Used:") then
            callback(last_custom_args)
        else
            last_custom_args = arg_presets[choice]
            callback(arg_presets[choice])
        end
    end)
end

return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        {
            "fredrikaverpil/neotest-golang",
        },
    },
    cmd = { "Neotest" },
    keys = {
        { "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File (Neotest)" },
        { "<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run All Test Files (Neotest)" },
        { "<leader>tr", function() require("neotest").run.run() end, desc = "Run Nearest (Neotest)" },
        { "<leader>ta", function()
            select_preset(function(args)
                local test_args = vim.deepcopy(args)
                table.insert(test_args, 1, "-args")
                require("neotest").run.run({ extra_args = { go_test_args = test_args } })
            end)
        end, desc = "Run Nearest with Args (Neotest)" },
        { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug Nearest (Neotest)" },
        { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run Last (Neotest)" },
        { "<leader>tL", function() require("neotest").run.run_last({ strategy = "dap" }) end, desc = "Debug Last (Neotest)" },
        { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary (Neotest)" },
        { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output (Neotest)" },
        { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel (Neotest)" },
        { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop (Neotest)" },
        { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Toggle Watch (Neotest)" },
    },
    opts = {
        -- Can be a list of adapters like what neotest expects,
        -- or a list of adapter names,
        -- or a table of adapter names, mapped to adapter configs.
        -- The adapter will then be automatically loaded with the config.
        -- Example for loading neotest-golang with a custom config
        adapters = {
            ["neotest-golang"] = {

                warn_test_name_dupes = false,
                go_test_args = {
                    "-v",
                    "-race",
                    "-count=1",
                    "-timeout=200s",
                },
                dap_go_enabled = true,
            },
        },
        status = { virtual_text = false },
        output = { open_on_run = true },
        output_panel = {
            enabled = true,
            open = "botright vsplit | vertical resize 80",
        },
        quickfix = {
            -- Overwriting lazyvim defaults:
            -- Disable automatically opening the quickfix tab when a test fails
            -- Can be manually opened with quickfix
            open = function()
                -- if LazyVim.has("trouble.nvim") then
                --     require("trouble").open({ mode = "quickfix", focus = false })
                -- else
                -- vim.cmd("copen")
                -- end
            end,
        },
    },
    config = function(_, opts)
        local neotest_ns = vim.api.nvim_create_namespace("neotest")
        vim.diagnostic.config({
            virtual_text = {
                format = function(diagnostic)
                    -- Replace newline and tab characters with space for more compact diagnostics
                    local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
                    return message
                end,
            },
        }, neotest_ns)

        -- Optional: Trouble integration (commented out since you may not need it)
        -- if require("lazy.core.config").plugins["trouble.nvim"] then
        --     opts.consumers = opts.consumers or {}
        --     opts.consumers.trouble = function(client)
        --         client.listeners.results = function(adapter_id, results, partial)
        --             if partial then return end
        --             local tree = assert(client:get_position(nil, { adapter = adapter_id }))
        --             local failed = 0
        --             for pos_id, result in pairs(results) do
        --                 if result.status == "failed" and tree:get_key(pos_id) then
        --                     failed = failed + 1
        --                 end
        --             end
        --             vim.schedule(function()
        --                 local trouble = require("trouble")
        --                 if trouble.is_open() then
        --                     trouble.refresh()
        --                     if failed == 0 then trouble.close() end
        --                 end
        --             end)
        --             return {}
        --         end
        --     end
        -- end

        -- Load adapters
        if opts.adapters then
            local adapters = {}
            for name, config in pairs(opts.adapters or {}) do
                if type(name) == "number" then
                    if type(config) == "string" then
                        config = require(config)
                    end
                    adapters[#adapters + 1] = config
                elseif config ~= false then
                    local adapter = require(name)
                    if type(config) == "table" and not vim.tbl_isempty(config) then
                        local meta = getmetatable(adapter)
                        if adapter.setup then
                            adapter.setup(config)
                        elseif adapter.adapter then
                            adapter.adapter(config)
                            adapter = adapter.adapter
                        elseif meta and meta.__call then
                            adapter = adapter(config)
                        else
                            error("Adapter " .. name .. " does not support setup")
                        end
                    end
                    adapters[#adapters + 1] = adapter
                end
            end
            opts.adapters = adapters
        end

        require("neotest").setup(opts)
    end,
}
