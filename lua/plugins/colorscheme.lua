return {
	-- Default theme. Highlight overrides live in lua/theme.lua so that the
	-- <leader>tt toggle can restore exactly the same look.
	{
		"AndreyGladkov/alabaster.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("theme").alabaster()
		end,
	},
	-- Rich theme, loaded on demand by the <leader>tt toggle
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
	},
	-- Treesitter highlighting, loaded on demand by the <leader>tt toggle.
	--
	-- Pinned to `master` deliberately: the rewritten `main` branch needs the
	-- tree-sitter CLI installed system-wide and does not support lazy-loading,
	-- both of which this on-demand toggle depends on. `master` builds parsers
	-- with a plain C compiler.
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		build = ":TSUpdate",
		lazy = true,
		main = "nvim-treesitter.configs",
		-- Both modules stay off on purpose: lua/theme.lua drives
		-- vim.treesitter.start/stop and parser installs itself, so the plugin
		-- is used only as a parser installer and query provider.
		--
		-- `auto_install` in particular cannot coexist with that: it installs
		-- parsers for every buffer whose FileType fires once the plugin is
		-- loaded, and two concurrent installs of the same parser clobber each
		-- other's temp directory ("Could not create tree-sitter-<lang>-tmp").
		opts = {
			highlight = { enable = false },
			auto_install = false,
			ensure_installed = {},
		},
	},
}
