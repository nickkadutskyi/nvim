if vim.fn.has("nvim-0.11") == 0 then
    Utils.theme.set_opt_background()
end

---@type LazySpec
return {
    { -- Sync theme with OS
        "f-person/auto-dark-mode.nvim",
        cond = function()
            return vim.fn.has("nvim-0.11") == 0
                and (vim.fn.has("nvim-0.9") == 0 or vim.api.nvim_get_vvar("servername") ~= "")
        end,
        ---@type AutoDarkModeOptions
        opts = {},
    },
}
