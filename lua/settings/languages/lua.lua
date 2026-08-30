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
    ---@type ide.Opts.Conform
    opts = {
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
    ---@type ide.Opts.Lsp
    opts = {
        clients = {
            ["emmylua_ls"] = {},
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

spec.add({
    "nvim-lspconfig",
    opts =
        ---@param opts ide.Opts.Lsp
        ---@return ide.Opts.Lsp
        function(_, opts)
            local client = opts.clients and opts.clients.emmylua_ls
            if not client then
                return opts
            end

            local dp = vim.fn.stdpath("data")
            local data_path = (type(dp) == "string" and dp or dp[1]) or vim.env.HOME .. "/.local/share/nvim"
            local pack_path = vim.fs.joinpath(data_path, "site", "pack")
            local ignore_dir = { "dev/opt" }
            local library = {
                {
                    path = pack_path,
                    ignoreDir = ignore_dir,
                },
            }
            for _, name in ipairs(require("ide.dev").get_active_plugin_names()) do
                table.insert(ignore_dir, "core/opt/" .. name)
                table.insert(library, vim.fs.joinpath(pack_path, "dev", "opt", "dev-" .. name, "lua"))
            end

            client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
                emmylua = {
                    workspace = {
                        library = library,
                    },
                },
            })
            return opts
        end,
})
