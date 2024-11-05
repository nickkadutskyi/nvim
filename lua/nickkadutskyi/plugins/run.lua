return {
    {
        -- Intellij run configurations
        -- TODO add ability to use Intllij run configurations from .run and .idea/runConfiguration
        -- TODO Add keybinding and popup similar to ChooseRunConfiguration in Intellij
        "stevearc/overseer.nvim",
        config = function()
            local overseer = require("overseer")
            local overseer_window = require("overseer.window")
            overseer.setup({})
            overseer.load_template("jetbrains_provider")

            -- Activate Run (Overseer)
            vim.keymap.set("n", "<leader>ar", function()
                local winid = vim.api.nvim_get_current_win()
                if winid ~= "" and (not overseer_window.is_open()) then
                    vim.cmd("CloseNetrw")
                    vim.cmd("CloseNetrw")
                    overseer.open()
                elseif overseer_window.is_open() and overseer_window.get_win_id() ~= winid then
                    vim.cmd("CloseNetrw")
                    vim.cmd("CloseNetrw")
                    overseer.open()
                else
                    overseer.close()
                end
                -- overseer.toggle()
            end, { noremap = true, desc = "[a]ctivate [r]un (Overseer)" })
        end,
    },
}
