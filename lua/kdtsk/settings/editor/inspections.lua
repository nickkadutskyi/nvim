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
    -- turns off diagnostics signs in gutter
    signs = false,
})

return {
    "folke/trouble.nvim",
    opts = {
        auto_close = true,
        warn_no_results = true,
        open_no_results = false,
        modes = {
            document_diagnostics = {
                mode = "diagnostics",
                filter = { buf = 0 },
                focus = true,
            },
            workspace_diagnostics = {
                mode = "diagnostics",
                filter = {},
                focus = true,
            },
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
            elseif trouble.is_open() and not trouble.is_open(mode) then
                trouble.close()
                trouble.open(mode)
            else
                trouble.close()
            end
        end
        vim.keymap.set("n", "<leader>tt", function()
            toggle_problems("document_diagnostics")
        end, { noremap = true })
        vim.keymap.set("n", "<leader>tT", function()
            toggle_problems("workspace_diagnostics")
        end, { noremap = true })
        vim.keymap.set("n", "]t", function()
            trouble._action("next")("document_diagnostics")
            -- trouble.next({ skip_groups = true, jump = true, mode = "diagnostics" })
        end, { noremap = true })
        vim.keymap.set("n", "[t", function()
            trouble._action("prev")("document_diagnostics")
            -- trouble.prev({ skip_groups = true, jump = true, mode = "diagnostics" })
        end, { noremap = true })
    end,
}
