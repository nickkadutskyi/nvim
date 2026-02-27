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
                            runtime = {
                                version = "LuaJIT",
                                -- path = runtime_path,
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
        opts = function(_, opts)
            local linters_to_use = {}
            if
                Utils.tools.is_component_enabled("lua", "selene", Utils.tools.purpose.INSPECTION, {
                    "selene.toml",
                })
            then
                table.insert(linters_to_use, "selene")
            end
            if
                Utils.tools.is_component_enabled("lua", "luacheck", Utils.tools.purpose.INSPECTION, {
                    ".luacheckrc",
                })
            then
                table.insert(linters_to_use, "luacheck")
            end
            return vim.tbl_deep_extend("force", opts, {
                linters_by_ft = {
                    lua = linters_to_use,
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
            })
        end,
    },
}
