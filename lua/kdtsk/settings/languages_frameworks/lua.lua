---@type LazySpec
return {
    { -- Language Servers
        "nvim-lspconfig",
        opts = {
            ---@type table<string,vim.lsp.ConfigLocal>
            servers = {
                ["lua_ls"] = {
                    settings = {
                        Lua = {
                            -- Disable telemetry
                            telemetry = { enable = false },
                            runtime = {
                                version = "LuaJIT",
                                -- path = runtime_path,
                            },
                            diagnostics = {
                                globals = { "vim" },
                            },
                            workspace = {
                                checkThirdParty = false,
                                -- Use VIMRUNTIME/lua because lazydev.nvim overrides runtime.path
                                -- from { "lua/?.lua" } to { "?.lua" }, so library entries must
                                -- point directly to the lua/ root for module resolution to work.
                                library = {
                                    vim.env.VIMRUNTIME .. "/lua",
                                    "${3rd}/luv/library",
                                },
                            },
                            hint = { enable = true },
                        },
                    },
                },
            },
        },
    },
    { -- Code Style
        "conform.nvim",
        opts = {
            formatters_by_ft = {
                lua = { "stylua", timeout_ms = 2000 },
            },
        },
    },
}
