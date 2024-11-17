return {
    {
        -- Intellij run configurations
        -- TODO add ability to use Intllij run configurations from .run and .idea/runConfiguration
        -- TODO Add keybinding and popup similar to ChooseRunConfiguration in Intellij
        "stevearc/overseer.nvim",
        config = function()
            local overseer = require("overseer")
            local overseer_window = require("overseer.window")
            require("overseer").setup({
                strategy = {
                    "toggleterm",
                    -- load your default shell before starting the task
                    use_shell = false,
                    -- overwrite the default toggleterm "auto_scroll" parameter
                    auto_scroll = nil,
                    -- have the toggleterm window close and delete the terminal buffer
                    -- automatically after the task exits
                    close_on_exit = false,
                    -- have the toggleterm window close without deleting the terminal buffer
                    -- automatically after the task exits
                    -- can be "never, "success", or "always". "success" will close the window
                    -- only if the exit code is 0.
                    quit_on_exit = "never",
                    -- open the toggleterm window when a task starts
                    open_on_start = false,
                    -- mirrors the toggleterm "hidden" parameter, and keeps the task from
                    -- being rendered in the toggleable window
                    hidden = true,
                    -- command to run when the terminal is created. Combine with `use_shell`
                    -- to run a terminal command before starting the task
                    on_create = nil,
                },
            })
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
            end, { noremap = true, desc = "Run: [a]ctivate [r]un tool window" })

            vim.keymap.set("n", "<leader>ct", function()
                -- overseer.run_template()
                 overseer.run_template({}, function(task)
                   if task then
                     -- overseer.run_action(task, 'open float')
                   end
                 end)
            end, { noremap = true, desc = "Run: [c]hoose [t]ask to run" })
        end,
    },
}
