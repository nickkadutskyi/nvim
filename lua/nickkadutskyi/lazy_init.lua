-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Initializing lazy.nvim
require("lazy").setup({
    spec = {
        { import = "nickkadutskyi.plugins" },
        {
            -- Detect tabstop and shiftwidth automatically
            "tpope/vim-sleuth",
        },
        --{
        --    "rachartier/tiny-inline-diagnostic.nvim", -- better diagnostics
        --    enabled = false,
        --    event = "VeryLazy", -- Or `LspAttach`
        --    config = function()
        --        -- Hides diagnostic virtual text
        --        vim.diagnostic.config({ virtual_text = false })
        --        require("tiny-inline-diagnostic").setup({
        --            options = {
        --                show_source = true,
        --                virt_texts = {
        --                    priority = 80,
        --                },
        --            },
        --        })
        --    end,
        --},

        -- -- ZERO LSP START
        -- -- Additional Config in ~/.config/nvim/after/plugin/lsp.lua
        -- {
        --     "VonHeikemen/lsp-zero.nvim",
        --     branch = "v3.x",
        --     lazy = true,
        --     config = false,
        --     init = function()
        --         -- Disable automatic setup, we are doing it manually
        --         vim.g.lsp_zero_extend_cmp = 0
        --         vim.g.lsp_zero_extend_lspconfig = 0
        --     end,
        -- },
        -- {
        --     "williamboman/mason.nvim",
        --     lazy = false,
        --     -- Uses default implementation
        --     -- config = true,
        --     config = function()
        --         require("mason").setup({
        --             ui = {
        --                 border = "rounded",
        --             },
        --         })
        --     end,
        -- },
        --
        -- -- Autocompletion
        -- {
        --     "hrsh7th/nvim-cmp",
        --     event = "InsertEnter",
        --     dependencies = {
        --         { "L3MON4D3/LuaSnip" },
        --     },
        --     config = function()
        --         -- Here is where you configure the autocompletion settings.
        --         local lsp_zero = require("lsp-zero")
        --         lsp_zero.extend_cmp()
        --
        --         -- And you can configure cmp even more, if you want to.
        --         local cmp = require("cmp")
        --         local cmp_action = lsp_zero.cmp_action()
        --
        --         cmp.setup({
        --             preselect = "item",
        --             completion = {
        --                 completeopt = "menu,menuone,noinsert",
        --             },
        --             formatting = lsp_zero.cmp_format(),
        --             mapping = cmp.mapping.preset.insert({
        --                 ["<C-Space>"] = cmp.mapping.complete(),
        --                 ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        --                 ["<C-d>"] = cmp.mapping.scroll_docs(4),
        --                 ["<C-f>"] = cmp_action.luasnip_jump_forward(),
        --                 ["<C-b>"] = cmp_action.luasnip_jump_backward(),
        --                 -- Confirm completion with enter
        --                 ["<CR>"] = cmp.mapping.confirm({ select = true }),
        --             }),
        --         })
        --     end,
        -- },
        --
        -- -- LSP
        -- {
        --     "neovim/nvim-lspconfig",
        --     cmd = { "LspInfo", "LspInstall", "LspStart" },
        --     event = { "BufReadPre", "BufNewFile" },
        --     dependencies = {
        --         { "hrsh7th/cmp-nvim-lsp" },
        --         { "williamboman/mason-lspconfig.nvim" },
        --     },
        --     config = function()
        --         -- This is where all the LSP shenanigans will live
        --         local lsp_zero = require("lsp-zero")
        --         lsp_zero.extend_lspconfig()
        --
        --         lsp_zero.on_attach(function(client, bufnr)
        --             -- see :help lsp-zero-keybindings
        --             -- to learn the available actions
        --             lsp_zero.default_keymaps({ buffer = bufnr })
        --
        --             if client.server_capabilities.documentSymbolProvider then
        --                 require("nvim-navic").attach(client, bufnr)
        --             end
        --         end)
        --
        --         -- Configure nil_ls for nix
        --         local caps = vim.tbl_deep_extend(
        --             "force",
        --             vim.lsp.protocol.make_client_capabilities(),
        --             require("cmp_nvim_lsp").default_capabilities(),
        --         -- File watching is disabled by default for neovim.
        --         -- See: https://github.com/neovim/neovim/pull/22405
        --             { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } }
        --         )
        --         require("lspconfig").nil_ls.setup({
        --             capabitilies = caps,
        --             settings = {
        --                 ["nil"] = {
        --                     testSetting = 42,
        --                     formatting = {
        --                         command = { "nixpkgs-fmt" },
        --                     },
        --                 },
        --             },
        --         })
        --
        --         -- Runs after require("mason").setup()
        --         require("mason-lspconfig").setup({
        --             ensure_installed = {
        --                 "lua_ls",
        --             },
        --             handlers = {
        --                 lsp_zero.default_setup,
        --                 lua_ls = function()
        --                     -- (Optional) Configure lua language server for neovim
        --                     local lua_opts = lsp_zero.nvim_lua_ls()
        --                     require("lspconfig").lua_ls.setup(lua_opts)
        --                 end,
        --                 emmet_ls = function()
        --                     require("lspconfig").emmet_ls.setup({
        --                         filetypes = {
        --                             "html",
        --                             "css",
        --                             -- […]
        --                             "php",
        --                             "sass",
        --                             "scss",
        --                             "vue",
        --                             "javascript",
        --                         },
        --                     })
        --                 end,
        --             },
        --         })
        --     end,
        -- },
        -- -- ZERO LSP END
        --
        --

        { -- For commenting
            "numToStr/Comment.nvim",
            opts = {
                -- add any options here
            },
            lazy = false,
        },
    },
    change_detection = {
        enable = true,
        notify = false,
    },
    ui = {
        border = "rounded",
        title = { { " Plugin Manager ", "JBFloatBorder" } },
    },
    dev = {
        path = "~/Developer/PE/0027",
        patterns = { "nickkadutskyi" },
        fallback = true,
    },
})
