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
		-- faster fzf in case of a large project
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
		-- Scrollbar
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
