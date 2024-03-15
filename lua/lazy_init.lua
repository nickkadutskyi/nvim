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
  {
    'tpope/vim-sleuth',   -- Detect tabstop and shiftwidth automatically
    "github/copilot.vim", -- AI Assistant
    {                     -- Useful plugin to show you pending keybinds.
      'folke/which-key.nvim',
      event = 'VimEnter', -- Sets the loading event to 'VimEnter'
      config = function() -- This is the function that runs, AFTER loading
        require('which-key').setup()

        -- Document existing key chains
        require('which-key').register {
          ['<leader>c'] = { name = '[C]hange & keep register', _ = 'which_key_ignore' },
          ['<leader>C'] = { name = '[C]hange line & keep register', _ = 'which_key_ignore' },
          ['<leader>d'] = { name = '[D]elete & keep register', _ = 'which_key_ignore' },
          ['<leader>D'] = { name = '[D]elete line & keep register', _ = 'which_key_ignore' },
          ['<leader>x'] = { name = '[D]elete char & keep register', _ = 'which_key_ignore' },
          ['<leader>p'] = { name = '[P]aste over selection & keep regiser', _ = 'which_key_ignore' },

          ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
          ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
          ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
        }
      end,
    },
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
              print("Treesitter is disabled due to file containing 50k col wide lines")
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
      opts = {
        ensure_installed = {
          "bash", "lua", "vim", "vimdoc", "json", "yaml", "regex", "html", "c",
          "php", "javascript", "typescript", "css", "gitignore", "http", "sql",
        },
        auto_install = true, -- Automatically install missing parsers
        -- sync_install = false, -- Install parsers synchronously
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<A-Up>',
            node_incremental = '<A-Up>',
            scope_incremental = '<C-s>',
            node_decremental = '<A-Down>'
          }
        }
      },
      config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
      end
    },
    { -- Color theme
      -- "devsjs/vim-jb", -- Forked my theme from this one
      "nick-kadutskyi/vim-jb",
      name = "vim-jb",
      lazy = true,
      dev = true, -- theme is in dev but falls back to my public GitHub repo
      init = function()
        -- Enables intalics
        vim.g.jb_enable_italics = 1
        -- JB defualt light theme
        vim.g.jb_style = "light"
        -- Sets default jb_style based on MacOs theme
        if vim.fn.has('macunix') == 1 then
          if io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null"):read() == "Dark" then
            vim.g.jb_style = "dark"
          end
        end
        -- Read hardcoded style from bash var
        local theme = os.getenv("theme")
        if theme ~= nil then
          -- If theme var provided enforce colorscheme style and don't auto change
          if theme == "light" or theme == "l" then
            vim.g.jb_style = "light"
          elseif theme == "dark" or theme == "d" then
            vim.g.jb_style = "dark"
          elseif theme == "mid" or theme == "m" then
            vim.g.jb_style = "mid"
          end
        end
      end,
      config = function()
        vim.cmd("colorscheme jb")
      end
    },
    { -- Auto dark mode
      "f-person/auto-dark-mode.nvim",
      config = function()
        local theme = os.getenv("theme")
        if theme == nil then
          require("auto-dark-mode").setup({
            set_dark_mode = function()
              vim.api.nvim_set_var("jb_style", "dark")
              vim.cmd("colorscheme jb")
            end,
            set_light_mode = function()
              vim.api.nvim_set_var("jb_style", "light")
              vim.cmd("colorscheme jb")
            end,
          })
        end
      end,
      dependencies = { "nick-kadutskyi/vim-jb" },
    },
    { "SmiteshP/nvim-navic", dependencies = { "neovim/nvim-lspconfig" } }, -- Adds location in status line

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
      config = function()
        require("fzf-lua").setup({
          "telescope", -- Sets telescope profile for look and feel
          fzf_colors = {
            ["fg"] = { "fg", "CursorLine" },
            ["bg"] = { "bg", "Normal" },
            ["hl"] = { "fg", "Comment" },
            ["fg+"] = { "fg", "Normal" },
            ["bg+"] = { "bg", "CursorLine" },
            ["hl+"] = { "fg", "Statement" },
            ["info"] = { "fg", "PreProc" },
            ["prompt"] = { "fg", "Conditional" },
            ["pointer"] = { "fg", "Exception" },
            ["marker"] = { "fg", "Keyword" },
            ["spinner"] = { "fg", "Label" },
            ["header"] = { "fg", "Comment" },
            ["gutter"] = { "bg", "EndOfBuffer" },
          },
          previewers = {
            builtin = {
              extensions = {
                ["svg"] = { "chafa" },
                ["png"] = { "chafa", "<file>" },
                ["jpg"] = { "chafa" },
              },
            },
          },
        })
      end
    },
    "lewis6991/gitsigns.nvim", -- Visibility for changes comparde to current git branch in the gutter
    "tpope/vim-fugitive",      -- For git diff
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
    { -- Code formatter
      "stevearc/conform.nvim",
      opts = {},
      config = function()
        require("conform").setup({
          formatters_by_ft = {
            -- lua = { "stylua" },
            -- Conform will run multiple formatters sequentially
            python = { "isort", "black" },
            -- Use a sub-list to run only the first available formatter
            javascript = { { "prettierd", "prettier" } },
          },
        })
      end
    },
    -- Comments
    {
      'numToStr/Comment.nvim',
      opts = {
        -- add any options here
      },
      lazy = false,
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
