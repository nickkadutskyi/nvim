return {
    { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = {
            "mfussenegger/nvim-dap",
            "williamboman/mason.nvim",
        },
        config = function()
            -- require("mason-nvim-dap").setup({
            --     ensure_installed = {
            --         "python",
            --         "node",
            --         "go",
            --         "ruby",
            --         "php",
            --         "rust",
            --         "dotnet",
            --     },
            -- })
            require("mason-nvim-dap").setup({
                -- Makes a best effort to setup the various debuggers with
                -- reasonable debug configurations
                automatic_setup = true,
                automatic_installation = false,

                -- You can provide additional configuration to the handlers,
                -- see mason-nvim-dap README for more information
                handlers = {
                    function(config)
                        require("mason-nvim-dap").default_setup(config)
                    end,
                    php = function(config)
                        config.configurations = {
                            {
                                type = "php",
                                request = "launch",
                                name = "Listen for XDebug",
                                port = 9003,
                                log = true,
                                -- localSourceRoot = vim.fn.getcwd(),
                                -- pathMappings = {
                                --     ["/var/www/html/"] = vim.fn.getcwd() .. "/",
                                -- },
                                -- hostname = "0.0.0.0",
                                -- hostname = "127.0.0.1",
                            },
                        }

                        require("mason-nvim-dap").default_setup(config) -- don't forget this!
                    end,
                },

                -- You'll need to check that you have the required things installed
                -- online, please don't ask me how to install them :)
                ensure_installed = {
                    -- Update this to ensure that you have the debuggers for the langs you want
                    "php",
                    "delve",
                },
            })

            vim.keymap.set("n", "<F5>", function()
                require("dap").continue()
            end)
            vim.keymap.set("n", "<F10>", function()
                require("dap").step_over()
            end)
            vim.keymap.set("n", "<F11>", function()
                require("dap").step_into()
            end)
            vim.keymap.set("n", "<F12>", function()
                require("dap").step_out()
            end)
            vim.keymap.set("n", "<Leader>db", function()
                require("dap").toggle_breakpoint()
            end)
            vim.keymap.set("n", "<Leader>B", function()
                require("dap").set_breakpoint()
            end)
            vim.keymap.set("n", "<Leader>lp", function()
                require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
            end)
            vim.keymap.set("n", "<Leader>dr", function()
                require("dap").repl.open()
            end)
            vim.keymap.set("n", "<Leader>dl", function()
                require("dap").run_last()
            end)
            vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
                require("dap.ui.widgets").hover()
            end)
            vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
                require("dap.ui.widgets").preview()
            end)
            vim.keymap.set("n", "<Leader>df", function()
                local widgets = require("dap.ui.widgets")
                widgets.centered_float(widgets.frames)
            end)
            vim.keymap.set("n", "<Leader>ds", function()
                local widgets = require("dap.ui.widgets")
                widgets.centered_float(widgets.scopes)
            end)
        end,
    },
}
