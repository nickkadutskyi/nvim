local utils = require("ide.utils")

--- MODULE DEFINITION ----------------------------------------------------------
local M = {}
local I = {}

---@type ide.Opts.Lsp
I.opts = {}

function M.setup(opts)
    require("editorconfig").properties.tools_lsp = M.handle_tools_lsp_declaration
    utils.autocmd.create("BufReadPost", {
        group = "ide-lint",
        callback = function(e)
            local filetype = vim.api.nvim_get_option_value("filetype", { buf = e.buf })
            if I.configured_ft[filetype] then
                return
            end

            M.handle_tools_lsp_declaration(e.buf, "", {})
        end,
    })
end

I.configured = false

--- Handling editorconfig integration for tools_lsp declaration
---@param bufnr integer
---@param val string
---@param opts? table
function M.handle_tools_lsp_declaration(bufnr, val, opts)
    if I.configured then
        return
    end
    I.configured = true
end

return M
