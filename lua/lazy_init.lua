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
		-- File search in current buffer
		-- Config in ~/.config/nvim/after/plugin/telescope.lua
		{
			"nvim-telescope/telescope.nvim",
			branch = "0.1.x",
			dependencies = { "nvim-lua/plenary.nvim" },
		},
		-- Telescope file browser action
		-- Config in ~/.config/nvim/after/plugin/telescope.lua
		{
			"nvim-telescope/telescope-file-browser.nvim",
			dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
		},
		-- Treesitter for syntax highlight
		-- Config in ~/.config/nvim/after/plugin/tresitter.lua
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
		},
		{
			"nvim-treesitter/playground",
		},
		-- Color themes
		-- Config in ~/.config/nvim/after/plugin/color.lua
		{
			-- "devsjs/vim-jb",
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
		-- Undo Tree
		-- Config in ~/.config/nvim/after/plugin/undotree.lua
		{
			"mbbill/undotree",
		},
		-- Git plugin
		{
			"tpope/vim-fugitive",
		},
		-- Shows sticky header for current context
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
			config = true,
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
					formatting = lsp_zero.cmp_format(),
					mapping = cmp.mapping.preset.insert({
						["<C-Space>"] = cmp.mapping.complete(),
						["<C-u>"] = cmp.mapping.scroll_docs(-4),
						["<C-d>"] = cmp.mapping.scroll_docs(4),
						["<C-f>"] = cmp_action.luasnip_jump_forward(),
						["<C-b>"] = cmp_action.luasnip_jump_backward(),
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
					},
				})
			end,
		},
		-- ZERO LSP END
		--
		-- Icons for Issues and for Telescope File Browser
		{
			"nvim-tree/nvim-web-devicons",
		},
		-- Provides connection of telescope with fzf (fuzzy search)
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
		-- Visibility for changes comparde to current git branch in the gutter
		{
			"lewis6991/gitsigns.nvim",
		},
		-- Scrollbar
		{
			"petertriho/nvim-scrollbar",
			config = function()
				require("scrollbar").setup({
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
			"mhartington/formatter.nvim",
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
			"xiyaowong/transparent.nvim",
			enabled = false,
			config = function()
				require("transparent").setup({
					extra_groups = {
						-- example of akinsho/nvim-bufferline.lua
						"BufferLineTabClose",
						"BufferlineBufferSelected",
						"BufferLineFill",
						"BufferLineBackground",
						"BufferLineSeparator",
						"BufferLineIndicatorSelected",
						"SignColumn",
						"GitGutter",
						"GitSignsChangedelete",
						"GitSignsAdd",
						"GitSignsDelete",
						"GitSignsTopdelete",
						"GitSignsUntracked",
						"GitSignsChange",
					},
					exclude_groups = {
						"CursorLine", -- Exlcudes it to show highlight like in IntelliJ
					},
				})
			end,
		},
	},
	-- Configs
	{
		dev = {
			path = "~/Developer/PE/0000",
			patterns = { "nick-kadutskyi" },
			fallback = true,
		},
	}
)
