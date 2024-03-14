-- Bootstrapping lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Initializing lazy.nvim
require("lazy").setup(
-- Plugins
  {
    -- AI Assistant
    { "github/copilot.vim" },
    -- Disables treesitter if the file has 100000 cols wide lines
    {
      "LunarVim/bigfile.nvim",
      lazy = false,
      event = { "FileReadPre", "BufReadPre", "User FileOpened" },
      config = function()
        require("bigfile").setup({
          -- filesize = 5, -- size of the file in MiB, the plugin round file sizes to the closest MiB
          -- pattern = { "*" }, -- autocmd pattern or function see <### Overriding the detection of big files>
          pattern = function(bufnr, filesize_mib)
            -- you can't use `nvim_buf_line_count` because this runs on BufReadPre
            local file_contents = vim.fn.readfile(vim.api.nvim_buf_get_name(bufnr))
            -- local file_length = #file_contents
            -- local filetype = vim.filetype.match({ buf = bufnr })
            local longest = 0
            for k, v in pairs(file_contents) do
              local len = #v
              if len > longest then
                longest = #v
                if len > 50000 then
                  break
                end
              end
            end

            if longest > 50000 then
              print("Treesitter is disabled due to file containing 100k col wide lines")
              return true
            end
          end,
          features = { -- features to disable
            -- "indent_blankline",
            -- "illuminate",
            -- "lsp",
            "treesitter",
            -- "syntax",
            -- "matchparen",
            -- "vimopts",
            -- "filetype",
          },
        })
      end,
    },
    -- Treesitter for syntax highlight
    -- Config in ~/.config/nvim/after/plugin/tresitter.lua
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
    },
    -- Color theme
    -- Config in ~/.config/nvim/after/plugin/color.lua
    {
      -- "devsjs/vim-jb", -- Forked my theme from this one
      "nick-kadutskyi/vim-jb",
      name = "vim-jb",
      lazy = true,
      dev = true, -- theme is in dev but falls back to my public GitHub repo
    },
    -- Auto dark mode
    -- Config in ~/.config/nvim/after/plugin/color.lua
    {
      "f-person/auto-dark-mode.nvim",
    },
    -- Adds location in status line
    {
      "SmiteshP/nvim-navic",
      dependencies = { "neovim/nvim-lspconfig" },
    },
    -- ZERO LSP START
    -- Additional Config in ~/.config/nvim/after/plugin/lsp.lua
    {
      "VonHeikemen/lsp-zero.nvim",
      branch = "v3.x",
      lazy = true,
      config = false,
      init = function()
        -- Disable automatic setup, we are doing it manually
        vim.g.lsp_zero_extend_cmp = 0
        vim.g.lsp_zero_extend_lspconfig = 0
      end,
    },
    {
      "williamboman/mason.nvim",
      lazy = false,
      -- Uses default implementation
      -- config = true,
      config = function()
        require("mason").setup({
          ui = {
            border = "rounded",
          },
        })
      end,
    },

    -- Autocompletion
    {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      dependencies = {
        { "L3MON4D3/LuaSnip" },
      },
      config = function()
        -- Here is where you configure the autocompletion settings.
        local lsp_zero = require("lsp-zero")
        lsp_zero.extend_cmp()

        -- And you can configure cmp even more, if you want to.
        local cmp = require("cmp")
        local cmp_action = lsp_zero.cmp_action()

        cmp.setup({
          preselect = "item",
          completion = {
            completeopt = "menu,menuone,noinsert",
          },
          formatting = lsp_zero.cmp_format(),
          mapping = cmp.mapping.preset.insert({
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-u>"] = cmp.mapping.scroll_docs(-4),
            ["<C-d>"] = cmp.mapping.scroll_docs(4),
            ["<C-f>"] = cmp_action.luasnip_jump_forward(),
            ["<C-b>"] = cmp_action.luasnip_jump_backward(),
            -- Confirm completion with enter
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
          }),
        })
      end,
    },

    -- LSP
    {
      "neovim/nvim-lspconfig",
      cmd = { "LspInfo", "LspInstall", "LspStart" },
      event = { "BufReadPre", "BufNewFile" },
      dependencies = {
        { "hrsh7th/cmp-nvim-lsp" },
        { "williamboman/mason-lspconfig.nvim" },
      },
      config = function()
        -- This is where all the LSP shenanigans will live
        local lsp_zero = require("lsp-zero")
        lsp_zero.extend_lspconfig()

        lsp_zero.on_attach(function(client, bufnr)
          -- see :help lsp-zero-keybindings
          -- to learn the available actions
          lsp_zero.default_keymaps({ buffer = bufnr })

          if client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, bufnr)
          end
        end)

        -- Runs after require("mason").setup()
        require("mason-lspconfig").setup({
          ensure_installed = {},
          handlers = {
            lsp_zero.default_setup,
            lua_ls = function()
              -- (Optional) Configure lua language server for neovim
              local lua_opts = lsp_zero.nvim_lua_ls()
              require("lspconfig").lua_ls.setup(lua_opts)
            end,
            emmet_ls = function()
              require("lspconfig").emmet_ls.setup({
                filetypes = {
                  "html",
                  "css",
                  -- […]
                  "php",
                  "sass",
                  "scss",
                  "vue",
                  "javascript",
                },
              })
            end,
          },
        })
      end,
    },
    -- ZERO LSP END
    --
    --
    -- Faster fzf in case of a large project
    -- DEPENDENCIES: Linux or Mac, fzf or skim, OPTIONAL: fd, rg, bat, delta, chafa
    {
      "ibhagwan/fzf-lua",
      -- optional for icon support
      dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    -- Visibility for changes comparde to current git branch in the gutter
    {
      "lewis6991/gitsigns.nvim",
    },
    -- For git diff
    {
      "tpope/vim-fugitive",
    },
    -- Scrollbar to also show git changes not visible in current view
    {
      "petertriho/nvim-scrollbar",
      config = function()
        require("scrollbar").setup({
          handlers = {
            -- to show my position in doc
            cursor = true,
            -- to see if I have any changes
            gitsigns = true,
            -- disables handle because it works shitty
            handle = false,
          },
          marks = {
            GitAdd = {
              text = "│",
            },
            GitChange = {
              text = "│",
            },
          },
        })
      end,
    },
    -- Code formatter
    -- Config ~/.config/nvim/after/plugin/formatter.lua
    {
      "stevearc/conform.nvim",
      opts = {},
    },
    -- Comments
    {
      "terrortylor/nvim-comment",
    },
    -- Visual guides
    {
      "xiyaowong/virtcolumn.nvim",
    },
    {
      "folke/trouble.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
    },
    -- Markdown preview
    {
      "epwalsh/obsidian.nvim",
      version = "*", -- recommended, use latest release instead of latest commit
      lazy = true,
      ft = "markdown",
      -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
      -- event = {
      --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
      --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
      --   "BufReadPre path/to/my-vault/**.md",
      --   "BufNewFile path/to/my-vault/**.md",
      -- },
      dependencies = {
        -- Required.
        "nvim-lua/plenary.nvim",

        -- see below for full list of optional dependencies 👇
      },
      opts = {
        -- see below for full list of options 👇
        follow_url_func = function(url)
          -- Open the URL in the default web browser.
          vim.fn.jobstart({ "open", url }) -- Mac OS
          -- vim.fn.jobstart({"xdg-open", url})  -- linux
        end,
        ui = {
          enable = false,
          hl_groups = {
            -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
            -- ObsidianTodo = { bold = true, fg = "#f78c6c" },
            -- ObsidianDone = { bold = true, fg = "#89ddff" },
            ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
            ObsidianTilde = { bold = true, fg = "#ff5370" },
            ObsidianRefText = { underline = true, fg = "#c792ea" },
            ObsidianExtLinkIcon = { fg = "#c792ea" },
            ObsidianTag = { italic = true, underline = true, cterm = { underline = true } },
            -- ObsidianHighlightText = { bg = "#75662e" },
            ObsidianHighlightText = { bg = "#FAECA1" },
          },
        },
      },
    },
  },
  -- Configs
  {
    ui = {
      border = "rounded",
      title = { { " Plugin Manager ", "JBFloatBorder" } },
    },
    dev = {
      path = "~/Developer/PE/0000",
      patterns = { "nick-kadutskyi" },
      fallback = true,
    },
  }
)
