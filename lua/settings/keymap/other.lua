local utils = require("ide.utils")
local pack = require("ide.pack")
--- MAPPINGS -------------------------------------------------------------------

require("ide.utils").run.now_if_arg_or_deferred(function()
    -- Treesitter Inspect builtin
    vim.keymap.set("n", "<leader>ip", "<cmd>Inspect<CR>", {
        desc = "Other:TS: [i]spect Treesitter [p]osition",
    })
    vim.keymap.set("n", "<leader>it", "<cmd>InspectTree<CR>", {
        desc = "Other:TS: [i]spect Treesitter [t]ree",
    })
end)

--- Context Actions
utils.run.on_lsp_attach(function(buf, client)
    -- TODO: review what UI I need for this
    -- LSP Code Action or Context Actions
    local function context_action()
        if pack.is_loaded("fzf-lua") then
            require("fzf-lua").lsp_code_actions({
                async = true,
                winopts = { title = " Context Actions ", title_pos = "left" },
            })
        else
            vim.lsp.buf.code_action()
        end
    end
    vim.keymap.set(
        { "n", "x" },
        "gra",
        context_action,
        { buffer = buf, desc = "Refactor: [g]o to [r]efactor > Context [a]ctions" }
    )
end)
