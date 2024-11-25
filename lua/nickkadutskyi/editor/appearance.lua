-- Sign column always visible
vim.opt.signcolumn = "yes"
-- Show line nubmers
vim.opt.number = true
-- Show line nubmers relative to the cursor position
vim.opt.relativenumber = true
-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = {
    tab = "» ",
    space = "‧",
    trail = "‧",
    extends = "⟩",
    nbsp = "␣",
}
-- Enables cursor line highlight groups
vim.opt.cursorline = true
-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 3
-- Adds visual guides
-- vim.opt.colorcolumn = "80,100,120" -- defined in plugin

---Tabs to show only file name without labels and path
function _G.custom_tabline()
    local tabline = ""
    for i = 1, vim.fn.tabpagenr("$") do
        -- Select the highlighting
        if i == vim.fn.tabpagenr() then
            tabline = tabline .. "%#TabLineSel#"
        else
            tabline = tabline .. "%#TabLine#"
        end

        -- Set the tab page number (for mouse clicks)
        tabline = tabline .. "%" .. i .. "T"

        -- Get the window number
        local winnr = vim.fn.tabpagewinnr(i)
        local buflist = vim.fn.tabpagebuflist(i)
        local bufnr = buflist[winnr]
        local bufname = vim.fn.bufname(bufnr)
        local bufmodified = vim.fn.getbufvar(bufnr, "&mod")

        -- Get the buffer name
        local name
        if bufname == "" then
            name = "[No Name]"
        elseif bufname:match("term://") then
            -- Get the terminal name
            local path_parts = vim.fn.split(bufname, ":")
            name = "term " .. path_parts[#path_parts]
        elseif bufname:match("diffview://") then
            -- Get the diffview name
            name = "diff " .. bufname:gsub(vim.fn.getcwd(), ""):gsub("diffview:///", "")
        elseif bufname:match("^.+://") then
            -- Keep full name for special buffers
            name = bufname
        else
            -- Get only the file name for regular files
            name = vim.fn.fnamemodify(bufname, ":t")
        end

        -- Add modified symbol
        if bufmodified == 1 then
            name = name .. " [+]"
        end

        tabline = tabline .. " " .. name .. " "
    end

    -- Fill with TabLineFill and reset tab page number
    tabline = tabline .. "%#TabLineFill#%T"

    return tabline
end

vim.opt.tabline = "%!v:lua.custom_tabline()"

return {
    { -- Visual guides
        "lukas-reineke/virt-column.nvim",
        opts = {
            -- Highlight groups from nickkadutskyi/jb.nvim
            highlight = {
                "General_Editor_Guides_VisualGuides",
                "General_Editor_Guides_VisualGuides",
                "General_Editor_Guides_HardWrapGuide",
            },
            char = "▕",
            virtcolumn = "80,100,120",
            exclude = { filetypes = { "netrw" } },
        },
    },
    { -- Indent guides
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {
            indent = { char = "▏" },
            -- disables underline
            scope = { show_start = false, show_end = false },
        },
    },
    { -- Error stripes and VCS status in Scrollbar
        "petertriho/nvim-scrollbar",
        dependencies = {
            "kevinhwang91/nvim-hlslens",
        },
        opts = {
            show = true,
            set_highlights = false,
            hide_if_all_visible = false,
            handlers = {
                diagnostic = true,
                gitsigns = true, -- Requires gitsigns
                handle = true,
                search = true, -- Requires hlslens
                cursor = false,
            },
            marks = {
                GitAdd = {
                    text = "│",
                },
                GitChange = {
                    text = "│",
                },
            },
        },
    },
}
