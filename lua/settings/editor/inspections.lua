local utils = require("ide.utils")
local spec = require("ide.spec.builder")

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

--- OPTIONS --------------------------------------------------------------------

-- Configure diagnostics with custom floating window and signs
utils.run.on_deferred(function()
    local function diagnostic_config(border, signs_text)
        border = border or "rounded"
        signs_text = signs_text or {}

        vim.diagnostic.config({
            update_in_insert = true,
            virtual_text = false,
            float = { -- [icon] [source]: [message] [code]
                focusable = true,
                border = border,
                scope = "cursor",
                source = true, -- Shows source of inspection in the front
                header = "",
                max_width = (function()
                    local columns = vim.o.columns
                    local width = math.floor(columns * 0.95)
                    return width <= 100 and width or 100
                end)(),
                prefix = "  ",
                suffix = function(diag) -- Adds error code in comment style in the end
                    local suffix_text = diag.code and "[" .. diag.code .. "] " or ""
                    if diag.message:find("\n") and diag.code then
                        suffix_text = "\n  " .. suffix_text
                    end
                    return " " .. suffix_text, "Comment"
                end,
            },
            -- Disables in gutter but Problem tool window will still show them
            signs = { severity = {}, text = signs_text },
        })
    end

    local diag_confed = false
    -- jb.nvim integration for borders and icons, but falls back to defaults if not loaded yet
    utils.run.on_load("jb.nvim", function()
        diag_confed = true
        diagnostic_config(require("jb.borders").borders.dialog.default_box, require("jb.icons").diagnostic)
    end)
    if not diag_confed then
        diagnostic_config()
    end
end)

--- PLUGINS --------------------------------------------------------------------

spec.add({
    "incline.nvim",
    opts = {
        render = function(props)
            return {
                { require("ide.incline").component_diagnostics(props) },
            }
        end,
    },
})

spec.add({
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
