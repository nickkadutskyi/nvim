local utils = require("ide.utils")
local spec_builder = require("ide.spec.builder")

--- AUTOCMDS -------------------------------------------------------------------

utils.run.now_if_arg_or_deferred(function()
    utils.autocmd.create({ "BufEnter" }, {
        group = "settings.turn-off-diagnostics-outside-projects",
        desc = "Disable diagnostics and spell checking for files outside of project root",
        callback = function(e)
            local root = vim.fn.getcwd()
            if not root or e.file and e.file ~= "" and not vim.startswith(e.file, root) then
                vim.diagnostic.enable(false, { bufnr = 0 })
                vim.opt_local.spell = false
            end
        end,
    })
end)

utils.autocmd.create("IdeDeferred", {
    once = true,
    desc = "Configure diagnostics with custom floating window and signs",
    callback = function()
        -- jb.nvim integration for borders and icons, but falls back to defaults if not loaded yet
        ---@type string|table
        local border = "rounded"
        local signs_text = {}
        utils.run.on_load("jb.nvim", function()
            border = require("jb.borders").borders.dialog.default_box
            signs_text = require("jb.icons").diagnostic
        end)

        vim.diagnostic.config({
            update_in_insert = true,
            virtual_text = false,
            -- [icon] [source]: [message] [code]
            float = {
                focusable = true,
                border = border,
                scope = "cursor",
                -- Shows source of inspection in the front
                source = true,
                header = "",
                -- max_width = 100,
                max_width = (function()
                    local columns = vim.o.columns
                    local width = math.floor(columns * 0.95)
                    return width <= 100 and width or 100
                end)(),
                prefix = "  ",

                -- -- Adds inspection icons to indicate severity
                -- prefix = function(diagnostic)
                --     local icon = Utils.icons.diagnostic[diagnostic.severity]
                --     local severity_name = vim.diagnostic.severity[diagnostic.severity]
                --     return " " .. icon .. " ", "DiagnosticSign" .. severity_name
                -- end,
                -- format = function(diagnostic)
                --     -- return "\n" .. diagnostic.message
                -- end,

                -- Adds error code in comment style in the end
                suffix = function(diagnostic)
                    local code = diagnostic.code
                    local suffix_text = code and "[" .. code .. "] " or ""
                    if diagnostic.message:find("\n") and code then
                        suffix_text = "\n  " .. suffix_text
                    end
                    return " " .. suffix_text, "Comment"
                end,
            },
            signs = {
                -- Disables in gutter but Problem tool window will still show them
                severity = {},
                text = signs_text,
            },
        })
    end,
})

--- PLUGINS --------------------------------------------------------------------

spec_builder.add({
    "incline.nvim",
    opts = {
        render = function(props)
            return {
                { Utils.incline.component_diagnostics(props) },
            }
        end,
    },
})

spec_builder.add({
    "trouble.nvim",
    ---@class trouble.Config
    opts = {
        auto_close = true,
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
        },
    },
})
