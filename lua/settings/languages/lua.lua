local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "lua", "luadoc", "luap" } } })

spec.add({
    "mfussenegger/nvim-lint",
    opts = { ---@type ide.Opts.Lint
        linters_by_ft = {
            lua = {
                { "selene", { "selene.toml" } },
                { "luachecke", { ".luacheckrc" } },
            },
        },
        linters = {
            selene = { nix_pkg = "selene" },
            luacheck = { nix_pkg = "luajitPackages.luacheck" },
        },
    },
})

spec.add({
    "conform.nvim",
    opts = { ---@type ide.Opts.Conform
        formatters_by_ft = {
            lua = { { "stylua", nil, nil, true, { timeout_ms = 2000 } } },
        },
    },
})

spec.add({
    "lazydev.nvim",
    opts = {
        -- Until lazy.nvim is present it won't find those in vim.pack unless provide a full path
        library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            { path = "inc-rename.nvim", words = { "inc_rename" } },
            { path = "snacks.nvim", words = { "Snacks" } },
            { path = "nvim-lint", words = { "lint%.Linter", "lint%.Parser", "lint%.parse" } },
            { path = "conform.nvim", words = { "conform%.setupOpts" } },
        },
    },
})

spec.add({
    "nvim-lspconfig",
    opts = { ---@type ide.Opts.Lsp
        clients = {
            ["lua_ls"] = {
                settings = {
                    Lua = {
                        -- Disable telemetry
                        telemetry = { enable = false },
                        runtime = {
                            version = "LuaJIT",
                            path = { -- This might be overriden by lazydev.nvim
                                "lua/?.lua",
                                "lua/?/init.lua",
                            },
                        },
                        diagnostics = {
                            globals = { "vim" },
                        },
                        workspace = {
                            checkThirdParty = false,
                            library = {
                                vim.env.VIMRUNTIME,
                                "${3rd}/luv/library",
                            },
                        },
                        hint = { enable = true },
                    },
                },
            },
        },
    },
})
