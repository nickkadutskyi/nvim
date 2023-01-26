local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

	-- File search in current buffer
	use({
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		requires = { { "nvim-lua/plenary.nvim" } },
	})

	-- Telescope file browser action
	use({ "nvim-telescope/telescope-file-browser.nvim" })

	-- Treesitter for syntax highlight
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})

	-- Themes
	use({
		"rose-pine/neovim",
		as = "rose-pine",
	})

	-- Auto dark mode
	use("f-person/auto-dark-mode.nvim")

	-- Undo Tree
	use("mbbill/undotree")

	-- Git plugin
	use("tpope/vim-fugitive")

	-- LSP
	use({
		"VonHeikemen/lsp-zero.nvim",
		requires = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" },
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },

			-- Autocompletion
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lua" },

			-- Snippets
			{ "L3MON4D3/LuaSnip" },
			{ "rafamadriz/friendly-snippets" },
		},
	})

	-- List of issues

	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("trouble").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			})
		end,
	})

	-- Tree view
	-- use({
	-- 	"nvim-tree/nvim-tree.lua",
	-- 	requires = {
	-- 		"nvim-tree/nvim-web-devicons", -- optional, for file icons
	-- 	},
	-- 	tag = "nightly", -- optional, updated every week. (see issue #1193)
	-- })

	-- Provides connection of telescope with fzf (fazzy search)
	use({
		"nvim-telescope/telescope-fzf-native.nvim",
		run = "make",
	})

	-- Provides visibility for changes compared to current git branch in the gutter
	use("airblade/vim-gitgutter")

	-- Help to jump anywhere (requires keybindings)
	--  use {
	--    'phaazon/hop.nvim',
	--    branch = 'v2', -- optional but strongly recommended
	--    config = function()
	--      -- you can configure Hop the way you like here; see :h hop-config
	--      require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
	--    end
	--  }

	-- Shows sticky header for current context
	use("nvim-treesitter/nvim-treesitter-context")

	-- Code formatter
	use("sbdchd/neoformat")

	-- Smooth scrolling
	use({
		"declancm/cinnamon.nvim",
		-- config = function()
		-- 	require("cinnamon").setup()
		-- end,
	})

	-- Visual guides
	use("xiyaowong/virtcolumn.nvim")

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
