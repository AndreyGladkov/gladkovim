return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			notifier = {
				enabled = true,
				timeout = 4000,
				style = "compact",
				top_down = true,
				margin = { top = 1, right = 1, bottom = 0 },
			},
			picker = {
				enabled = true,
				sources = {
					files = {
						hidden = true,
					},
					grep = {
						hidden = true,
					},
				},
				win = {
					input = {
						keys = {
							["<Esc>"] = { "close", mode = { "n", "i" } },
						},
					},
				},
			},
			rename = {
				enabled = true,
			},
		},
		keys = {
			{
				"<leader>n",
				function()
					Snacks.notifier.show_history()
				end,
				desc = "Notification History",
			},
			-- File search
			{
				"<C-p>",
				function()
					Snacks.picker.files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>fg",
				function()
					Snacks.picker.git_files()
				end,
				desc = "Find Git Files",
			},
			{
				"<leader>fr",
				function()
					Snacks.picker.recent()
				end,
				desc = "Recent Files",
			},
			{
				"<leader>fb",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			-- Grep / substring search
			{
				"<S-p>",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep",
			},
			-- {
			-- 	"<S-p>",
			-- 	function()
			-- 		Snacks.picker.grep_word()
			-- 	end,
			-- 	desc = "Grep Word (visual or cursor)",
			-- 	mode = { "n", "x" },
			-- },
			{
				"<leader>sb",
				function()
					Snacks.picker.lines()
				end,
				desc = "Buffer Lines",
			},
			{
				"<leader>sB",
				function()
					Snacks.picker.grep_buffers()
				end,
				desc = "Grep Open Buffers",
			},
			-- Search in directory under cursor (from neo-tree or current file dir)
			{
				"<leader>fd",
				function()
					local dir = vim.fn.expand("%:p:h")
					Snacks.picker.files({ cwd = dir })
				end,
				desc = "Find Files in Current Dir",
			},
			{
				"<leader>sd",
				function()
					local dir = vim.fn.expand("%:p:h")
					Snacks.picker.grep({ cwd = dir })
				end,
				desc = "Grep in Current Dir",
			},
			-- Search by file mask/extension
			{
				"<leader>fe",
				function()
					Snacks.picker.files({ args = { "-e", "lua" } })
				end,
				desc = "Find Lua Files",
			},
			-- LSP (gd and gr are native in keymapping.lua)
			{
				"gD",
				function()
					Snacks.picker.lsp_declarations()
				end,
				desc = "Goto Declaration",
			},
			{
				"gI",
				function()
					Snacks.picker.lsp_implementations()
				end,
				desc = "Goto Implementation",
			},
			{
				"gy",
				function()
					Snacks.picker.lsp_type_definitions()
				end,
				desc = "Goto Type Definition",
			},
			{
				"<leader>ss",
				function()
					Snacks.picker.lsp_symbols()
				end,
				desc = "LSP Symbols",
			},
			{
				"<leader>sS",
				function()
					Snacks.picker.lsp_workspace_symbols()
				end,
				desc = "LSP Workspace Symbols",
			},
			-- Rename file (integrates with neo-tree)
			{
				"<leader>cR",
				function()
					Snacks.rename.rename_file()
				end,
				desc = "Rename File",
			},
			-- Other useful
			{
				"<leader>/",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>:",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
		},
	},
}
