Utils.on_later(function()
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
end)

return {
    {
        "folke/trouble.nvim",
        ---@class trouble.Config
        opts = {
            auto_close = true,
            warn_no_results = true,
            open_no_results = false,
            max_items = 5000,
            signs = {},
            win = {
                wo = {
                    winhighlight = "Normal:TroubleNormal,NormalNC:TroubleNormalNC,EndOfBuffer:TroubleNormal,CursorLine:NetrwCursorLine,FloatBorder:ToolWindowFloatBorder",
                },
            },
            modes = {
                document_diagnostics = {
                    title = "{hl:TroubleTitle}Problems{hl} "
                        .. "{hl:TroubleTabSelected} File{hl}"
                        .. "{hl:TroubleTabSelectedCount}{count}{hl} "
                        .. "Project Errors",
                    mode = "diagnostics",
                    filter = { buf = 0 },
                    focus = true,
                    win = {
                        type = "float",
                        relative = "editor",
                        position = { 0.95, 0 },
                        size = { width = 1, height = 15 },
                        border = { "‾", "‾", "‾", "", "", "", "", "" },
                    },
                },
                workspace_diagnostics = {
                    title = "{hl:TroubleTitle}Problems{hl} "
                        .. " File "
                        .. "{hl:TroubleTabSelected} Project Errors{hl}"
                        .. "{hl:TroubleTabSelectedCount}{count}{hl}",
                    mode = "diagnostics",
                    filter = {},
                    focus = true,
                    win = {
                        type = "float",
                        relative = "editor",
                        position = { 0.95, 0 },
                        size = { width = 1, height = 15 },
                        border = { "‾", "‾", "‾", "", "", "", "", "" },
                    },
                },
                symbols = {
                    multiline = false,
                    title = "{hl:TroubleTitle}Structure{hl} {count}",
                    desc = "Structure",
                    focus = true,
                    win = {
                        -- type = "float",
                        -- size = { width = 50, height = 0.99 },
                        -- position = { 0, 0 },
                        -- border = { "", "", "", "▕", "", "", "", "" },
                        size = 50,
                        position = "left",
                    },
                    filter = {
                        -- remove Package since luals uses it for control flow structures
                        ["not"] = { ft = "lua", kind = "Package" },
                        any = {
                            -- PHP: only show class name, constructor, properties and methods
                            { ft = "php", kind = { "Class", "Constructor", "Property", "Method", "Field" } },
                            -- non-PHP: fall back to default list
                            {
                                ["not"] = { ft = "php" },
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
                                    "Null",
                                    -- "Variable",
                                    "Object",
                                    "Array",
                                },
                            },
                            -- all symbol kinds for help / markdown files
                            ft = { "help", "markdown" },
                        },
                    },
                },
            },
        },
        config = function(_, opts)
            local trouble = require("trouble")

            -- Do it here for performance reasons because Utils runs setmetatable for icons
            opts.icons = { kinds = Utils.icons.kind }
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
