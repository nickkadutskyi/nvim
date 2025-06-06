---@type LazySpec
return {
    { -- Color scheme enhancement
        "nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "lua",
                "luadoc",
                "luap", -- for regex patterns (Lua Patterns)
            })
        end,
    },
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
                            -- runtime = {
                            --     version = "LuaJIT",
                            --     path = runtime_path,
                            -- },
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
    },
    { -- Code Style
        "conform.nvim",
        opts = {
            formatters_by_ft = {
                lua = { "stylua", timeout_ms = 2000 },
            },
        },
    },
    { -- Quality Tools
        "nvim-lint",
        opts = {
            linters_by_ft = {
                lua = { "luacheck", "selene" },
            },
            ---@type table<string, lint.LinterLocal>
            linters = {
                selene = {
                    nix_pkg = "selene",
                },
                luacheck = {
                    nix_pkg = "luajitPackages.luacheck",
                },
            },
        },
    },
}
