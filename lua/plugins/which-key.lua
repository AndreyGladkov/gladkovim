return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			-- Show popup after pressing Leader with no delay
			delay = 0,
			icons = {
				mappings = false,
			},
			spec = {
				{ "<leader>f", group = "find", icon = "🔍" },
				{ "<leader>s", group = "search", icon = "🔎" },
				{ "<leader>c", group = "code", icon = "💻" },
				{ "<leader>d", group = "diagnostics", icon = "🩺" },
				{ "<leader>b", group = "buffer", icon = "📄" },
				{ "<leader>u", group = "plantuml", icon = "📊" },
				{ "<leader>g", group = "git", icon = "🔀" },
			},
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps",
			},
		},
	},
}

