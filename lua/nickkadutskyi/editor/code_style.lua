---Config
-- Soft wrap
vim.opt.wrap = false
-- Soft wrap at line break - disabled for now
vim.opt.linebreak = false
-- Better indentation for wrapped lines
if vim.fn.has("linebreak") == 1 then
    vim.opt.breakindent = true
    vim.opt.showbreak = "↳ "
    vim.opt.breakindentopt = { shift = 0, min = 20, sbr = true }
end

-- Handled via .editorconfig
-- vim.opt.textwidth = 120 -- max_line_length
vim.opt.tabstop = 2 -- tab_width
vim.opt.expandtab = true -- indent_style
vim.opt.fileencoding = "utf-8" -- charset
vim.opt.softtabstop = 2 -- indent_size
vim.opt.shiftwidth = 2 -- indent_size

-- Indents next line if current is indented
vim.opt.autoindent = true
vim.opt.smartindent = true
-- Allow to move to one column past the end of the line
vim.opt.virtualedit = "onemore"

---@type LazySpec
return {
    { -- Code formatting configuration
        "stevearc/conform.nvim",
        dependencies = { "mason.nvim" },
        opts = {
            default_format_opts = {
                lsp_format = "fallback",
                stop_after_first = true,
            },
        },
        config = function(_, opts)
            require("conform").setup(opts)

            -- Keymap
            vim.keymap.set("n", "<leader>rc", require("conform").format, {
                desc = "Code: [r]eformat [c]ode",
            })
        end,
    },
    { -- Code formatting tools installation
        "zapling/mason-conform.nvim",
        dependencies = { "mason.nvim", "conform.nvim" },
        opts = { ignore_install = {} },
        config = function(_, opts)
            -- Manually install code format tools if missing in the system
            vim.api.nvim_create_user_command("CodeFormattersInstall", function()
                require("mason-conform").setup(opts)
            end, {})
        end,
    },
}
