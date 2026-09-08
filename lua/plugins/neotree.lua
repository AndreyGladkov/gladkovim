return {
	-- File explorer
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons", -- optional, but recommended
			"folke/snacks.nvim", -- integration with snacks.picker
		},
		opts = {
			filesystem = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
			},
			event_handlers = {
				{
					event = "neo_tree_buffer_enter",
					handler = function()
						vim.opt_local.relativenumber = true
					end,
				},
			},
			window = {
				mappings = {
					["<leader>ff"] = "snacks_picker_files_in_dir",
					["<leader>fw"] = "snacks_picker_grep_in_dir",
					["Y"] = "copy_path",
				},
			},
			commands = {
				snacks_picker_files_in_dir = function(state)
					local node = state.tree:get_node()
					local path = node.type == "directory" and node.path or vim.fn.fnamemodify(node.path, ":h")
					Snacks.picker.files({ cwd = path })
				end,
				copy_path = function(state)
					local node = state.tree:get_node()
					local path = vim.fn.fnamemodify(node.path, ":.:r")
					vim.fn.setreg("+", path)
					vim.notify("Copied: " .. path)
				end,
				snacks_picker_grep_in_dir = function(state)
					local node = state.tree:get_node()
					local path = node.type == "directory" and node.path or vim.fn.fnamemodify(node.path, ":h")
					Snacks.picker.grep({ cwd = path })
				end,
			},
		},
	},
	-- Keeps LSP informed when files are renamed/moved from the explorer
	{
		"antosha417/nvim-lsp-file-operations",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-neo-tree/neo-tree.nvim", -- makes sure that this loads after Neo-tree.
		},
		config = function()
			require("lsp-file-operations").setup()
		end,
	},
}
