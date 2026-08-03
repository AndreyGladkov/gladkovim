return {
	{ "folke/lazy.nvim" },
	-- File explorer
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons", -- optional, but recommended
			"folke/snacks.nvim", -- integration with snacks.picker
		},
		opts = {
			open_on_setup = true,
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
		lazy = false,
	},
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
	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		lazy = false,
		opts = {
			options = {
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				globalstatus = true,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { { "filename", path = 1 } },
				lualine_x = {
					{
						function()
							local clients = vim.lsp.get_clients({ bufnr = 0 })
							if #clients == 0 then return "" end
							local names = {}
							for _, c in ipairs(clients) do
								table.insert(names, c.name)
							end
							return " " .. table.concat(names, ", ")
						end,
					},
					"filetype",
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		},
	},
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
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		opts = {
			options = {
				mode = "buffers", -- show open buffers as tabs
				separator_style = "thin",
				always_show_bufferline = true,
				show_buffer_close_icons = true,
				show_close_icon = false,
				diagnostics = "nvim_lsp",
				diagnostics_indicator = function(count, level)
					local icon = level:match("error") and " " or " "
					return icon .. count
				end,
				custom_filter = function(buf_number)
					if vim.bo[buf_number].buftype == "quickfix" then
						return false
					end
					return true
				end,
				offsets = {
					{
						filetype = "neo-tree",
						text = "Explorer",
						text_align = "center",
						separator = true,
					},
				},
				sort_by = "insert_after_current",
			},
		},
	},
  {
    "yetone/avante.nvim",
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = vim.fn.has "win32" ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
      provider = "deepseek",
      providers = {
        ollama = {
          endpoint = "http://127.0.0.1:11434",
          model = "qwen3:30b-a3b-q4_K_M",
        },
        deepseek = {
          __inherited_from = "openai",
          endpoint = "https://llmgtw.hhdev.ru/proxy/deepseek",
          model = "deepseek-chat",
          api_key_name = "AVANTE_API_KEY",
        },
        glm = {
          __inherited_from = "openai",
          endpoint = "https://llm-gateway.pyn.ru/proxy/glm5-fp8/v1",
          api_key_name = "AVANTE_PYN_API_KEY",
        },
        openrouter = {
          __inherited_from = "openai",
          endpoint = "https://openrouter.ai/api/v1",
          model = "qwen/qwen3-235b-a22b:free",
        },
      },
    },
  }
}
