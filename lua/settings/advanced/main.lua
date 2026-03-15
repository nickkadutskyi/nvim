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
            (vim.hl or vim.highlight).on_yank()
        end,
    })
    utils.run.on_deferred(function()
        -- Starts LSP logs rotation
        -- TODO: move Utils from kdtsk to ide
        Utils.lsp.rotate_lsp_logs()
        vim.fn.timer_start(3600000, Utils.lsp.rotate_lsp_logs, { ["repeat"] = -1 })
    end)
end)

--- PLUGINS --------------------------------------------------------------------

spec.add({
    "harpoon",
    opts = { settings = { save_on_toggle = true } },
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
