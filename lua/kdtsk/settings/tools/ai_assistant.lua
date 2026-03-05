---@type LazySpec
return {
    {
        "nvim-lspconfig", -- Language Servers
        opts = function(_, opts)
            vim.lsp.inline_completion.enable()

            vim.keymap.set("i", "<Tab>", function()
                if not vim.lsp.inline_completion.get() then
                    return "<Tab>"
                end
            end, { expr = true, desc = "AI: Accept suggestion (LSP inline completion)" })
            vim.keymap.set({ "i", "n" }, "<A-]>", function()
                vim.lsp.inline_completion.select({ count = 1 })
            end, { expr = true, desc = "AI: Next inline suggestion" })
            vim.keymap.set({ "i", "n" }, "<A-[>", function()
                vim.lsp.inline_completion.select({ count = -1 })
            end, { expr = true, desc = "AI: Previous inline suggestion" })

            return vim.tbl_deep_extend("force", opts, {
                ---@type table<string,vim.lsp.ConfigLocal>
                servers = {
                    ["copilot"] = {
                        settings = {
                            telemetry = {
                                telemetryLevel = "off",
                            },
                        },
                    },
                },
            })
        end,
    },
}
