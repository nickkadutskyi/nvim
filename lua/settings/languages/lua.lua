local spec = require("ide.spec.builder")

spec.add({ "nvim-treesitter", opts = { ensure_installed = { "lua", "luadoc", "luap" } } })

spec.add({
    "mfussenegger/nvim-lint",
    ---@type ide.Opts.Lint
    opts = {
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
    opts = {
        formatters_by_ft = {
            lua = { { "stylua", nil, nil, true, { timeout_ms = 2000 } } },
        },
    },
})

spec.add({
    "lazydev.nvim",
    opts = {
        library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            -- { path = "lazy.nvim", words = { "Lazy" } },
            -- { path = "inc-rename.nvim", words = { "inc_rename" } },
            -- { path = "nvim-gitstatus", words = { "GitStatus" } },
            -- { path = "auto-dark-mode.nvim", words = { "AutoDarkMode" } },
            -- { path = "jb.icons", words = { "jb.icons" } },
            -- { path = "snacks.nvim", words = { "Snacks" } },
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
})
