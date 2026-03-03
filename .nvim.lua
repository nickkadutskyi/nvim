vim.g.settings = { a = 1 }
vim.api.nvim_exec_autocmds("User", { pattern = "SettingsLoaded" })
