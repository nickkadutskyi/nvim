return {
    {
        -- Detect tabstop and shiftwidth automatically
        "tpope/vim-sleuth",
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                globalstatus = true,
                -- component_separators = { left = "", right = "" },
                -- component_separators = { left = "|", right = "|" },
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                always_divide_middle = true,
            },
            sections = {
                lualine_a = {
                    -- project abbreviation
                    function()
                        local rootPath = vim.fn.getcwd()
                        local inputstr = vim.fs.basename(rootPath)
                        local firstChars = {}
                        for str in string.gmatch(inputstr, "([^-_,%s.]+)") do
                            table.insert(firstChars, string.upper(string.sub(str, 1, 1)))
                        end
                        return (firstChars[1] or "")
                            .. (firstChars[2] or string.upper(string.sub(inputstr, 2, 2)) or "")
                    end,
                    -- project name
                    function()
                        local rootPath = vim.fn.getcwd()
                        return vim.fs.basename(rootPath)
                    end,
                },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = {
                    {
                        "filetype",
                        padding = { left = 1, right = 0 },
                        icon_only = true,
                    },
                    {
                        "filename",
                        file_status = true,
                        newfile_status = true,
                        path = 1,
                        symbols = { newfile = "[new]", unnamed = "[no name]" },
                    },
                    "searchcount",
                    function()
                        return require("nvim-navic").get_location()
                    end,
                },
                lualine_x = {},
                lualine_y = { "progress" },
                lualine_z = { "mode", "location" },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { "filename" },
                lualine_x = { "location" },
                lualine_y = {},
                lualine_z = {},
            },
        },
    },
}
