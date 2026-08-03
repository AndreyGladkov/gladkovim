return {
	-- Completion engine
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- LSP completion source + enhanced capabilities (enables auto-imports)
			"hrsh7th/cmp-nvim-lsp",
			-- Buffer word completion
			"hrsh7th/cmp-buffer",
			-- File path completion
			"hrsh7th/cmp-path",
			-- Snippet engine (required by nvim-cmp)
			{
				"L3MON4D3/LuaSnip",
				version = "v2.*",
				build = "make install_jsregexp",
			},
			-- LuaSnip completion source
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			-- Load custom snippets
			require("snippets")

			-- Black border for completion and documentation windows
			vim.api.nvim_set_hl(0, "BorderBG", { fg = "#000000" })

			-- Deduplication: track seen words per completion session
			local seen_words = {}
			cmp.event:on("menu_opened", function()
				seen_words = {}
			end)

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},

				mapping = cmp.mapping.preset.insert({
					-- Scroll documentation window
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					-- Trigger completion manually
					["<C-Space>"] = cmp.mapping.complete(),
					-- Cancel completion
					["<C-e>"] = cmp.mapping.abort(),
					-- Confirm selection (only if explicitly selected)
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					-- Tab navigation through completion items
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),

				sources = cmp.config.sources({
					{ name = "nvim_lsp", priority = 1000 },
					{ name = "luasnip", priority = 750 },
					{ name = "path", priority = 500 },
				}, {
					{ name = "buffer", priority = 250 },
				}),

				-- Show completion item kind with icons
				formatting = {
					format = function(entry, vim_item)
						local kind_icons = {
							Text = "󰉿",
							Method = "󰆧",
							Function = "󰊕",
							Constructor = "",
							Field = "󰜢",
							Variable = "󰀫",
							Class = "󰠠",
							Interface = "",
							Module = "",
							Property = "󰜢",
							Unit = "󰑭",
							Value = "󰎧",
							Enum = "",
							Keyword = "󰌋",
							Snippet = "",
							Color = "󰏘",
							File = "󰈙",
							Reference = "󰈇",
							Folder = "󰉋",
							EnumMember = "",
							Constant = "󰏿",
							Struct = "󰙅",
							Event = "",
							Operator = "󰆕",
							TypeParameter = "",
						}
						vim_item.kind = (kind_icons[vim_item.kind] or "") .. " " .. vim_item.kind

						-- Source label
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[Snip]",
							buffer = "[Buf]",
							path = "[Path]",
						})[entry.source.name]

						return vim_item
					end,
				},

				-- Completion window style
				window = {
					completion = cmp.config.window.bordered({
						winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:Visual,Search:None",
						border = "single",
					}),
					documentation = cmp.config.window.bordered({
						winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:Visual,Search:None",
						border = "single",
					}),
				},
			})
		end,
	},
}
