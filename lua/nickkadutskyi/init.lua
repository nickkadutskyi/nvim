-- Define as much as possible in .vimrc to share configs with vim and ideavim
local vimrc = vim.fn.expand("~/.vimrc")
if vim.fn.filereadable(vimrc) then
    vim.cmd.source(vimrc)
end

-- Load plugins
require("nickkadutskyi.lazy_init")

-- If opened a dir set it as current dir to help narrow down fzf scope
if vim.fn.isdirectory(vim.fn.expand("%")) == 1 then
    vim.api.nvim_set_current_dir(vim.fn.expand("%"))
elseif vim.fn.filereadable(vim.fn.expand("%")) == 1 then
    vim.api.nvim_set_current_dir(vim.fn.expand("%:p:h"))
end

-- Auto commands
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local NickKadutskyiGroup = augroup("NickKadutskyi", {})

local nnoremap = require("nickkadutskyi.keymap").nnoremap
local conform = require("conform")

-- FIXME do i need to move this to lsp.lua config?
-- Adds mappings for LSP
autocmd("LspAttach", {
    group = NickKadutskyiGroup,
    callback = function(e)
        local bufnr = e.buf
        local client = vim.lsp.get_client_by_id(e.data.client_id)
        if client ~= nil and client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, bufnr)
        end
        -- lsp.on_attach(function(client, bufnr)
        --     lsp.default_keymaps({ buffer = e.bufnr })

        -- if client.server_capabilities.documentSymbolProvider then
        --     require("nvim-navic").attach(e.client, bufnr)
        --     end
        -- end)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function()
            vim.lsp.buf.definition()
        end, opts)
        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover()
        end, opts)
        vim.keymap.set("n", "<leader>vws", function()
            vim.lsp.buf.workspace_symbol()
        end, opts)
        vim.keymap.set("n", "<leader>vd", function()
            vim.diagnostic.open_float()
        end, opts)
        vim.keymap.set("n", "<leader>vca", function()
            vim.lsp.buf.code_action()
        end, opts)
        vim.keymap.set("n", "<leader>vrr", function()
            vim.lsp.buf.references()
        end, opts)
        vim.keymap.set("n", "<leader>vrn", function()
            vim.lsp.buf.rename()
        end, opts)
        vim.keymap.set("i", "<C-h>", function()
            vim.lsp.buf.signature_help()
        end, opts)
        vim.keymap.set("n", "]d", function()
            vim.diagnostic.goto_next()
        end, opts)
        vim.keymap.set("n", "[d", function()
            vim.diagnostic.goto_prev()
        end, opts)
    end,
})

-- Add all file into global variable
vim.g.all_files_str = ""
local rootPath = vim.fn.getcwd()
-- Check if it's a git repo
vim.fn.jobstart("git rev-parse --is-inside-work-tree", {
    cwd = rootPath,
    on_exit = function() end,
    on_stdout = function(_, data)
        local t = ""
        for _, d in pairs(data) do
            t = t .. d
        end
        if string.find(t, "true") then
            -- Get all files in git repo
            vim.fn.jobstart("git ls-files | xargs basename", {
                cwd = rootPath,
                on_exit = function() end,
                on_stdout = function(_, dataInternal)
                    for _, d in pairs(dataInternal) do
                        vim.g.all_files_str = vim.g.all_files_str .. ", " .. d
                    end
                    vim.g.all_files_str = vim.g.all_files_str .. ", end"
                end,
                on_stderr = function() end,
            })
        end
    end,
    on_stderr = function(_, data)
        -- do nothing if not a git repository because it can amoun to a lot of files
        --
        -- local t = "" .. next(data)
        -- for _, d in pairs(data) do
        --   t = t .. d
        -- end
        -- if string.find(t, "not a git repository") then
        --   -- Get all files in directory excluding some folders
        --   vim.fn.jobstart(
        --     'find "' .. rootPath .. '/" -type f ' ..
        --     '! -path "*node_modules/*" ' ..
        --     '! -path "*vendor/*" ' ..
        --     '! -path "*.idea/sonarlint*" ' ..
        --     '! -path "*.git/*" ' ..
        --     ' -exec basename {} \\;',
        --     {
        --       cwd = rootPath,
        --       on_exit = function()
        --       end,
        --       on_stdout = function(_, dataInternal)
        --         for _, d in pairs(dataInternal) do
        --           vim.g.all_files_str = vim.g.all_files_str .. ", " .. d
        --         end
        --         vim.g.all_files_str = vim.g.all_files_str .. ", end"
        --       end,
        --       on_stderr = function()
        --       end
        --     }
        --   )
        -- end
    end,
    stderr_buffered = false,
    stdout_buffered = false,
})

-- NEOVIM SPECIFIC SETTINGS (keep as much as possible in .vimrc)

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Remove cmd line to allow more space
vim.opt.cmdheight = 0

-- make zsh files recognized as sh for bash-ls & treesitter because there is no parser for zsh
vim.filetype.add({
    extension = {
        zsh = "sh",
        sh = "sh", -- force sh-files with zsh-shebang to still get sh as filetype
        scpt = function() -- detect if it's AppleScript or JavaScript for osascript
            if vim.fn.search("osascript -l JavaScript", "nw") ~= 0 then
                return "javascript"
            end
            return "applescript"
        end,
    },
    filename = {
        [".zshrc"] = "sh",
        [".zshenv"] = "sh",
        [".zpath"] = "sh",
        [".zprofile"] = "sh",
    },
})

-- NEOVIM SPECIFIC MAPPINGS (keep as much as possible in .vimrc)

-- Formatting
-- Reformat code with Conform.nvim which might fallback to LSP
-- nnoremap("<leader>cf", function()
--     conform.format()
-- end)
-- Reformat code with LSP
nnoremap("<leader>clf", vim.lsp.buf.format)

-- Vim Fuigitive
-- Git Satus
-- nnoremap("<leader>gs", ":Git<CR>")

-- Diagnostics builtin
-- nnoremap("[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
-- nnoremap("]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
-- nnoremap("<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
-- nnoremap("<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Treesitter Inspect builtin
nnoremap("<leader>ti", ":Inspect<CR>")
nnoremap("<leader>tti", ":InspectTree<CR>")

-- Obsidian
-- nnoremap("fl", function()
--     if require("obsidian").util.cursor_on_markdown_link() then
--         return "<cmd>ObsidianFollowLink<CR>"
--     else
--         return "fl"
--     end
-- end, { noremap = false, expr = true })

-- FEATUERS

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
