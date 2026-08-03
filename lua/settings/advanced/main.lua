local utils = require("ide.utils")
local spec = require("ide.spec.builder")

--- AUTOCMDS -------------------------------------------------------------------
utils.run.now_if_arg_or_deferred(function()
    utils.autocmd.create({ "BufWritePre" }, {
        group = "settings.auto-create-dir",
        desc = "Auto create directory when saving a file",
        callback = function(event)
            if event.match:match("^%w%w+:[\\/][\\/]") then
                return
            end
            local file = vim.uv.fs_realpath(event.match) or event.match
            vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
        end,
    })
    utils.autocmd.create({ "FocusGained", "TermClose", "TermLeave" }, {
        group = "settings.checktime",
        desc = "Check if we need to reload the file when it changed",
        callback = function()
            if vim.o.buftype ~= "nofile" then
                vim.cmd("checktime")
            end
        end,
    })
    utils.autocmd.create("TextYankPost", {
        group = "settings.highlight-yank",
        desc = "Highlight yanked text",
        callback = function()
            (vim.hl or vim.highlight).hl_op()
        end,
    })
    utils.run.on_deferred(function()
        -- Starts LSP logs rotation
        require("ide.lsp").rotate_lsp_logs()
        vim.fn.timer_start(3600000, require("ide.lsp").rotate_lsp_logs, { ["repeat"] = -1 })
    end)
end)

--- PLUGINS --------------------------------------------------------------------

spec.add({
    "harpoon",
    opts = {
        settings = { save_on_toggle = true },
        -- Default select uses bufadd+bufload which can leave a freshly opened
        -- buffer marked 'modified' (lualine [+]) even though nothing changed.
        -- :edit goes through the normal open path and avoids that.
        default = {
            select = function(list_item, _, options)
                if list_item == nil then
                    return
                end

                local Extensions = require("harpoon.extensions")
                options = options or {}

                local path = list_item.value
                local bufnr = vim.fn.bufnr(("^%s$"):format(vim.fn.escape(path, "^$.*[]~\\")))
                local set_position = bufnr == -1 or not vim.api.nvim_buf_is_loaded(bufnr)

                if options.vsplit then
                    vim.cmd.vsplit()
                elseif options.split then
                    vim.cmd.split()
                elseif options.tabedit then
                    vim.cmd.tabedit(vim.fn.fnameescape(path))
                    bufnr = vim.api.nvim_get_current_buf()
                    set_position = true
                elseif bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
                    vim.api.nvim_set_current_buf(bufnr)
                else
                    vim.cmd.edit(vim.fn.fnameescape(path))
                    bufnr = vim.api.nvim_get_current_buf()
                    set_position = true
                end

                if set_position and list_item.context then
                    local lines = vim.api.nvim_buf_line_count(bufnr)
                    local row = math.min(list_item.context.row or 1, lines)
                    local row_text = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)
                    local col = math.min(list_item.context.col or 0, row_text[1] and #row_text[1] or 0)
                    pcall(vim.api.nvim_win_set_cursor, 0, { row, col })
                end

                Extensions.extensions:emit(Extensions.event_names.NAVIGATE, {
                    buffer = bufnr,
                })
            end,
        },
    },
    after = function(_, opts)
        local harpoon = require("harpoon")
        local harpoon_extensions = require("harpoon.extensions")

        harpoon.setup(opts)

        harpoon:extend(harpoon_extensions.builtins.highlight_current_file())
        harpoon:extend(harpoon_extensions.builtins.navigate_with_number())
        harpoon:extend({
            -- Clear the list if the only item in the list is nil
            LIST_CHANGE = function()
                if harpoon:list():length() == 1 and harpoon:list():get(1) == nil then
                    vim.schedule(function()
                        harpoon:list():clear()
                    end)
                end
            end,
        })
    end,
})

spec.add({
    -- "folke/snacks.nvim",
    "snacks.nvim",
    ---@type snacks.Config
    opts = {
        ---@class snacks.bigfile.Config
        bigfile = { enabled = true },
        -- Moves git status to the right side of the row numbers like in IntelliJ
        statuscolumn = {
            enabled = true,
            folds = {
                open = true, -- show open fold icons
                git_hl = true, -- use Git Signs hl for fold icons
            },
        },
        image = {
            enabled = true,
            formats = {
                "png",
                "jpg",
                "jpeg",
                "gif",
                "bmp",
                "webp",
                "tiff",
                "heic",
                "avif",
                "mp4",
                "mov",
                "avi",
                "mkv",
                "webm",
                "pdf",
                "svg",
            },
        },
    },
})
