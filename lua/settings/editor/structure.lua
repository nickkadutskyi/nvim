local spec_builder = require("ide.spec.builder")

spec_builder.add({
    "folke/trouble.nvim",
    ---@class trouble.Config
    opts = {
        modes = {
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
                        -- Commented this to let this table through the event.data needed during vim.pack.add/update
                        -- all symbol kinds for help / markdown files
                        -- ft = { "help", "markdown" },
                    },
                },
            },
        },
    },
})
