return {
	-- Theme
	{
		"AndreyGladkov/alabaster.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("alabaster")

			vim.opt.background = "light"
			local set_hl = vim.api.nvim_set_hl
			set_hl(0, "Normal", { bg = "#FFFFFF" })
			set_hl(0, "WinSeparator", { fg = "#000000", bg = "NONE" })
		end,
	},
	-- Catppuccin theme (lazy, toggled by hotkey)
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
	},
	-- Treesitter (lazy, toggled by hotkey)
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = true,
		opts = {
			highlight = { enable = true },
			auto_install = true,
		},
	},
}
