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
    { -- Code Style
        "conform.nvim",
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
            },
        },
    },
    { -- Quality Tools
        "nvim-lint",
        opts = function()
            local lint = require("lint")
            lint.linters_by_ft["lua"] = { "luacheck" }
            vim.list_extend(lint.linters.luacheck.args, {
                "--globals",
                "vim",
                "lvim",
                "reload",
            })
            -- Run Lua linters that use stdin
            vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "BufWritePost" }, {
                group = vim.api.nvim_create_augroup("nickkadutskyi-lua-lint-stdin", { clear = true }),
                pattern = { "*.lua" },
                callback = function(e)
                    lint.try_lint({ "luacheck" })
                end,
            })
        end,
    },
}
