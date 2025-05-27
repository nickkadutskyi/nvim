-- Diagnostics config
vim.diagnostic.config({
    update_in_insert = true,
    virtual_text = false,
    -- [icon] [source]: [message] [code]
    float = {
        focusable = true,
        -- NOTE: currently couldn't find any good border pattern
        -- It looks fine in light but not in dark
        border = "rounded",
        scope = "cursor",
        -- Shows source of inspection in the front
        source = true,
        header = "",
        -- Adds inspection icons to indicate severity
        prefix = function(diagnostic)
            local icon = Utils.icons.diagnostic[diagnostic.severity]
            local severity_name = vim.diagnostic.severity[diagnostic.severity]
            return " " .. icon .. " ", "DiagnosticSign" .. severity_name
        end,
        -- Adds error code in comment style in the end
        suffix = function(diagnostic)
            local code = diagnostic.code
            return code and " [" .. code .. "]" or "", "Comment"
        end,
    },
    signs = {
        -- Disables in gutter but Problem tool window will still show them
        severity = {},
        text = Utils.icons.diagnostic,
    },
})

return {
    {
        "folke/snacks.nvim",
        keys = {
            {
                "<leader>ss",
                function()
                    Snacks.picker.lsp_symbols({
                        layout = { preset = "sidebar", preview = false },
                    })
                end,
                desc = "LSP Symbols",
            },
        },
        ---@class snacks.picker.Config
        opts = {
            picker = {
                sources = {
                    lsp_symbols = {
                        filter = {
                            default = {
                                "Class",
                                "Constructor",
                                "Enum",
                                "Field",
                                "Function",
                                "Interface",
                                "Method",
                                "Module",
                                "Namespace",
                                "Package",
                                "Property",
                                "Struct",
                                "Trait",
                                "String",
                                "Number",
                                "Null",
                                "Variable",
                                "Boolean",
                                "Object",
                                "Array",
                                "Keyword",
                            },
                        },
                    },
                },
            },
        },
    },
    {
        "folke/trouble.nvim",
        ---@class trouble.Config
        opts = {
            auto_close = true,
            warn_no_results = true,
            open_no_results = false,
            max_items = 5000,
            signs = {},
            modes = {
                document_diagnostics = {
                    title = "{hl:TroubleTitle}Problems{hl} "
                        .. "{hl:TroubleTabSelected} File{hl}"
                        .. "{hl:TroubleTabSelectedCount}{count}{hl} "
                        .. "Project Errors",
                    mode = "diagnostics",
                    filter = { buf = 0 },
                    focus = true,
                },
                workspace_diagnostics = {
                    title = "{hl:TroubleTitle}Problems{hl} "
                        .. " File "
                        .. "{hl:TroubleTabSelected} Project Errors{hl}"
                        .. "{hl:TroubleTabSelectedCount}{count}{hl}",
                    mode = "diagnostics",
                    filter = {},
                    focus = true,
                },
                symbols = {
                    multiline = false,
                    title = "{hl:TroubleTitle}Structure{hl} {count}",
                    desc = "Structure",
                    focus = true,
                    win = {
                        size = 50,
                        position = "left",
                    },
                    filter = {
                        -- remove Package since luals uses it for control flow structures
                        ["not"] = { ft = "lua", kind = "Package" },
                        any = {
                            -- all symbol kinds for help / markdown files
                            ft = { "help", "markdown" },
                            -- default set of symbol kinds
                            kind = {
                                "Class",
                                "Constructor",
                                "Enum",
                                "Field",
                                "Function",
                                "Interface",
                                "Method",
                                "Module",
                                "Namespace",
                                "Package",
                                "Property",
                                "Struct",
                                "Trait",
                                "String",
                                "Number",
                            },
                        },
                    },
                },
            },
            icons = {
                kinds = Utils.icons.kind,
            },
        },
        config = function(_, opts)
            local trouble = require("trouble")
            trouble.setup(opts)

            ---@type fun(mode?: string|table)
            local toggle_problems = function(mode)
                mode = mode or "diagnostics"
                local curr_buf_name = vim.api.nvim_buf_get_name(0)

                if curr_buf_name ~= "" and (not trouble.is_open() or trouble.is_open(mode)) then
                    trouble.open(mode)
                -- vim.schedule(function()
                --     require("trouble.view.render"):fold_level({ level = 2 })
                -- end)
                elseif trouble.is_open() and not trouble.is_open(mode) then
                    trouble.close()
                    trouble.open(mode)
                -- vim.schedule(function()
                --     require("trouble.view.render"):fold_level({ level = 2 })
                -- end)
                else
                    trouble.close()
                end
            end

            vim.keymap.set("n", "<localleader>tp", function()
                toggle_problems("document_diagnostics")
            end, { desc = "Problems: [t]oggle [p]roblem tool window" })
            vim.keymap.set("n", "<leader>tp", function()
                toggle_problems("workspace_diagnostics")
            end, { desc = "Problems: [t]oggle [p]roblem tool window" })

            vim.keymap.set("n", "<localleader>as", function()
                toggle_problems("symbols")
            end, { desc = "Structure: [a]ctivate [s]tructure" })

            vim.keymap.set("n", "]p", function()
                trouble._action("next")("document_diagnostics")
            end, { desc = "Problems: Next problem" })
            vim.keymap.set("n", "[p", function()
                trouble._action("prev")("document_diagnostics")
            end, { desc = "Problems: Previous problem" })
        end,
    },
}
