local spec_builder = require("ide.spec.builder")

---TODO: move to snacks.nvim and style snacks.nvim notify
spec_builder.add({
    "nvim-notify",
    after = function(_, opts)
        require("notify").setup(opts)

        -- Override vim.notify to use nvim-notify
        ---@diagnostic disable-next-line: duplicate-set-field
        vim.notify = function(message, level, nopts)
            nopts = nopts or {}
            if nopts.title == nil then
                nopts.title = "Notification"
            end
            return require("notify")(message, level, nopts)
        end

        -- Map LSP window/showMessage to vim.notify
        local severity = { "error", "warn", "info", "info" }
        vim.lsp.handlers["window/showMessage"] = function(_, method, params)
            local client = vim.lsp.get_client_by_id(params.client_id) or {}
            vim.notify(method.message, severity[method.type], { title = "LSP: " .. (client.name or "Unknown") })
        end
    end,
    opts = {
        minimum_width = 50,
        max_width = 50,
        render = "wrapped-compact",
        icons = { WARN = "" },
        top_down = false,
        -- Using custom stages to provide my own border and padding
        stages = {
            function(state)
                local next_height = state.message.height + 2
                local next_row =
                    require("notify.stages.util").available_slot(state.open_windows, next_height, "bottom_up")
                if not next_row then
                    return nil
                end
                return {
                    relative = "editor",
                    anchor = "NE",
                    width = state.message.width,
                    height = state.message.height,
                    col = vim.opt.columns:get() - 1,
                    row = next_row - 1,
                    border = require("jb.borders").borders.notification,
                    style = "minimal",
                }
            end,
            function()
                return {
                    col = vim.opt.columns:get() - 1,
                    time = true,
                }
            end,
        },
    },
})
