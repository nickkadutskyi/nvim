-- Bootstrapping lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Initializing lazy.nvim
require("lazy").setup(
  {
    'tpope/vim-sleuth',                 -- Detect tabstop and shiftwidth automatically
    {
      "supermaven-inc/supermaven-nvim", -- AI Assistant
      config = function()
        require("supermaven-nvim").setup({
          log_level = "error",
        })
      end,
    },
    "tpope/vim-fugitive",               -- For git diff
    {
      "lukas-reineke/virt-column.nvim", -- Visual guides
      opts = {
        highlight = {
          'General_Editor_Guides_VisualGuides',
          'General_Editor_Guides_VisualGuides',
          'General_Editor_Guides_HardWrapGuide'
        },
        char = "▕"
      },
      config = function(_, opts) require("virt-column").setup(opts) end
    },
    {
      "LunarVim/bigfile.nvim", -- Disables treesitter if the file matches some pattern
      lazy = false,
      event = { "FileReadPre", "BufReadPre", "User FileOpened" },
      config = function()
        require("bigfile").setup({
          pattern = function(bufnr, _)
            for _, v in pairs(vim.fn.readfile(vim.api.nvim_buf_get_name(bufnr))) do
              if #v > 30000 then
                print("Treesitter and LSP are disabled.")
                return true
              end
            end
          end,
          features = { "lsp", "treesitter" }, -- features to disable
        })
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter", -- Treesitter for syntax highlight (check after/queries for customizations)
      build = ":TSUpdate",
      enabled = true,
      opts = {
        ensure_installed = {
          "bash", "lua", "vim", "vimdoc", "yaml", "regex", "html", "c",
          "php", "javascript", "typescript", "css", "gitignore", "http", "sql",
          "comment",
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
    {
      "nvim-tree/nvim-web-devicons", -- For getting pretty icons, but requires a Nerd Font.
      config = function()
        require("nvim-web-devicons").setup({
          override = { -- your personnal icons can go here (to override)
            zsh = { icon = "", color = "#428850", cterm_color = "65", name = "Zsh" },
          },
          default = true,          -- globally enable default icons (default to false)
          strict = true,           -- globally enable "strict" selection of icons (default to false)
          override_by_filename = { -- same as `override` but for overrides by filename (requires `strict` to be true)
            [".gitignore"] = { icon = "", color = "#f1502f", name = "Gitignore" },
          },
          override_by_extension = { -- same as `override` but for overrides by extension (requires `strict` to be true)
            ["log"] = { icon = "", color = "#81e043", name = "Log" },
          },
        })
      end
    },
    {
      "rachartier/tiny-inline-diagnostic.nvim", -- better diagnostics
      event = "VeryLazy",                       -- Or `LspAttach`
      config = function()
        -- Hides diagnostic virtual text
        vim.diagnostic.config({ virtual_text = false })
        require('tiny-inline-diagnostic').setup({
          options = {
            show_source = true,
            virt_texts = {
              priority = 80,
            },
          }
        })
      end
    },
    {
      "nickkadutskyi/jb.nvim", -- My new color scheme inspired by IntelliJ
      name = "jb.nvim",
      lazy = true,
      dev = true,
      init = function()
        if vim.fn.has('macunix') == 1 then -- Sets default jb_style based on MacOs theme
          if io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null"):read() == "Dark" then
            vim.o.background = "dark"
          end
        end
        local theme = os.getenv("theme") -- Read hardcoded style from bash var
        if theme ~= nil then             -- If theme var provided enforce colorscheme style
          if theme == "light" or theme == "l" then
            vim.o.background = "light"
          elseif theme == "dark" or theme == "d" then
            vim.o.background = "dark"
          end
        end
      end,
      config = function()
        vim.cmd('colorscheme jb')
      end
    },
    -- {
    --   "nick-kadutskyi/vim-jb", -- My color theme (forked from devsjs/vim-js)
    --   enabled = false,
    --   name = "vim-jb",
    --   lazy = true,
    --   dev = true,                          -- theme is in dev but falls back to my public GitHub repo
    --   init = function()
    --     vim.g.jb_enable_italics = 1        -- Enables intalics
    --     vim.g.jb_style = "light"           -- JB defualt light theme
    --     if vim.fn.has('macunix') == 1 then -- Sets default jb_style based on MacOs theme
    --       if io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null"):read() == "Dark" then
    --         vim.g.jb_style = "dark"
    --       end
    --     end
    --     local theme = os.getenv("theme") -- Read hardcoded style from bash var
    --     if theme ~= nil then             -- If theme var provided enforce colorscheme style
    --       if theme == "light" or theme == "l" then
    --         vim.g.jb_style = "light"
    --       elseif theme == "dark" or theme == "d" then
    --         vim.g.jb_style = "dark"
    --       end
    --     end
    --   end,
    --   config = function()
    --     vim.cmd("colorscheme jb")
    --   end
    -- },
    {
      "f-person/auto-dark-mode.nvim", -- Auto dark mode
      config = function()
        local theme = os.getenv("theme")
        if theme == nil then -- Run auto dark mode only if theme is not hardcoded
          require("auto-dark-mode").setup({
            update_interval = 400,
            set_dark_mode = function()
              vim.api.nvim_set_option_value("background", "dark", {})
              vim.cmd("colorscheme jb")
            end,
            set_light_mode = function()
              vim.api.nvim_set_option_value("background", "light", {})
              vim.cmd("colorscheme jb")
            end,
          })
        end
      end,
      dependencies = { "nickkadutskyi/jb.nvim" },
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

        -- Configure nil_ls for nix
        local caps = vim.tbl_deep_extend(
          'force',
          vim.lsp.protocol.make_client_capabilities(),
          require('cmp_nvim_lsp').default_capabilities(),
          -- File watching is disabled by default for neovim.
          -- See: https://github.com/neovim/neovim/pull/22405
          { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } }
        );
        require 'lspconfig'.nil_ls.setup {
          capabitilies = caps,
          settings = {
            ['nil'] = {
              testSetting = 42,
              formatting = {
                command = { "nixpkgs-fmt" },
              },
            },
          },
        }

        -- Runs after require("mason").setup()
        require("mason-lspconfig").setup({
          ensure_installed = {
            "lua_ls",
          },
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
    { -- Scrollbar to also show git changes not visible in current view
      "petertriho/nvim-scrollbar",
      config = function()
        require("scrollbar").setup({
          handlers = {
            cursor = true,   -- to show my position in doc
            gitsigns = true, -- to see if I have any changes
            handle = false,  -- disables handle because it works shitty
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
        require("scrollbar.handlers.gitsigns").setup()
      end,
    },
    { -- Code formatter
      "stevearc/conform.nvim",
      opts = {},
      config = function()
        require("conform").setup({
          formatters_by_ft = {
            lua = { "stylua" },
            -- Conform will run multiple formatters sequentially
            python = { "isort", "black" },
            -- Use a sub-list to run only the first available formatter
            javascript = { { "prettierd", "prettier" } },
            css = { { "prettierd", "prettier" } },
            php = { "php_cs_fixer" }
          },
        })
      end
    },

    { -- For commenting
      'numToStr/Comment.nvim',
      opts = {
        -- add any options here
      },
      lazy = false,
    },
    { -- Visibility for changes compared to current git branch in the gutter
      "lewis6991/gitsigns.nvim",
      config = function()
        require('gitsigns').setup {
          signs                        = {
            add          = { text = '┃' },
            change       = { text = '┃' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '║' },
          },
          signs_staged_enable          = true,
          signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
          numhl                        = false, -- Toggle with `:Gitsigns toggle_numhl`
          linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
          word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
          watch_gitdir                 = {
            follow_files = true
          },
          attach_to_untracked          = true,
          current_line_blame           = true, -- Toggle with `:Gitsigns toggle_current_line_blame`

          current_line_blame_opts      = {
            virt_text = true,
            virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
            delay = 400,
            ignore_whitespace = false,
          },
          current_line_blame_formatter = '<author>, <author_time:%m/%d/%y>, <author_time:%I:%M %p> · <summary>',
          sign_priority                = 6,
          update_debounce              = 100,
          status_formatter             = nil,   -- Use default
          max_file_length              = 40000, -- Disable if file is longer than this (in lines)
          preview_config               = {
            -- Options passed to nvim_open_win
            border = 'single',
            style = 'minimal',
            relative = 'cursor',
            row = 0,
            col = 1
          },
          yadm                         = {
            enable = false
          },
          on_attach                    = function(bufnr)
            local gitsigns = require('gitsigns')

            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation
            -- map('n', ']c', function()
            --   if vim.wo.diff then
            --     vim.cmd.normal({ ']c', bang = true })
            --   else
            --     gitsigns.nav_hunk('next')
            --   end
            -- end)

            -- map('n', '[c', function()
            --   if vim.wo.diff then
            --     vim.cmd.normal({ '[c', bang = true })
            --   else
            --     gitsigns.nav_hunk('prev')
            --   end
            -- end)

            -- Actions
            map('n', '<leader>hs', gitsigns.stage_hunk)
            map('n', '<leader>hr', gitsigns.reset_hunk)
            map('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
            map('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
            map('n', '<leader>hS', gitsigns.stage_buffer)
            map('n', '<leader>hu', gitsigns.undo_stage_hunk)
            map('n', '<leader>hR', gitsigns.reset_buffer)
            map('n', '<leader>hp', gitsigns.preview_hunk)
            map('n', '<leader>hb', function() gitsigns.blame_line { full = true } end)
            map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
            map('n', '<leader>hd', gitsigns.diffthis)
            map('n', '<leader>hD', function() gitsigns.diffthis('~') end)
            map('n', '<leader>td', gitsigns.toggle_deleted)

            -- Text object
            map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
          end
        }
      end
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
      enabled = false,
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
    -- UNNECESSARY
    -- {                     -- Useful plugin to show you pending keybinds.
    --   'folke/which-key.nvim',
    --   event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    --   config = function() -- This is the function that runs, AFTER loading
    --     require('which-key').setup()
    --
    --     -- Document existing key chains
    --     -- require('which-key').register {
    --       -- ['<leader>c'] = { name = '[C]hange & keep register', _ = 'which_key_ignore' },
    --       -- ['<leader>C'] = { name = '[C]hange line & keep register', _ = 'which_key_ignore' },
    --       -- ['<leader>d'] = { name = '[D]elete & keep register', _ = 'which_key_ignore' },
    --       -- ['<leader>D'] = { name = '[D]elete line & keep register', _ = 'which_key_ignore' },
    --       -- ['<leader>x'] = { name = '[D]elete char & keep register', _ = 'which_key_ignore' },
    --       -- ['<leader>p'] = { name = '[P]aste over selection & keep regiser', _ = 'which_key_ignore' },
    --       --
    --       -- ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
    --       -- ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
    --       -- ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
    --     -- }
    --   end,
    -- },
  },
  { -- Configs
    ui = {
      border = "rounded",
      title = { { " Plugin Manager ", "JBFloatBorder" } },
    },
    dev = {
      path = "~/Developer/PE/0027",
      patterns = { "nickkadutskyi" },
      fallback = true,
    },
  }
)
