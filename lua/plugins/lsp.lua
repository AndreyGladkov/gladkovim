return {
	{
		"williamboman/mason.nvim",
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "mason.nvim" },
		opts = {
			ensure_installed = { "ts_ls", "eslint", "cssls", "basedpyright", "ruff", "emmet_language_server", "sqlls", "jdtls" },
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "mason-lspconfig.nvim", "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			vim.diagnostic.config({
				virtual_text = {
					source = "if_many",
					spacing = 4,
					prefix = "●",
				},
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "✘",
						[vim.diagnostic.severity.WARN] = "▲",
						[vim.diagnostic.severity.HINT] = "⚑",
						[vim.diagnostic.severity.INFO] = "»",
					},
				},
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = {
					border = "rounded",
					source = "if_many",
					header = "",
					prefix = function(diag)
						local level = vim.diagnostic.severity[diag.severity]
						local icons = { ERROR = "✘ ", WARN = "▲ ", HINT = "⚑ ", INFO = "» " }
						return icons[level] or "", "Diagnostic" .. level
					end,
				},
			})

			-- TS/JS
			vim.lsp.config("vtsls", {
				capabilities = capabilities,
                filetypes = {
                  "javascript",
                  "javascriptreact",
                  "typescript",
                  "typescriptreact",
                },
                settings = {
                  vtsls = {
                      autoUseWorkspaceTsdk = true,
                      tsconfigModifier = {
                        compilerOptions = {
                            allowJs = true,
                            checkJs = true,
                            jsx = "react", 
                        },
                    }
                  },
                  javascript = {
                      suggest = {
                          completeFunctionCalls = true,
                      },
                  },
                },
			})

            -- vim.api.nvim_create_autocmd({ "FileType" }, {
            --     pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
            --     callback = function(args)
            --         -- Ищем корень проекта по характерным файлам
            --         local root_dir = vim.fs.root(args.buf, { "tsconfig.json", "package.json", ".git" })
            --         
            --         -- Принудительно запускаем и прикрепляем vtsls к текущему файлу
            --         vim.lsp.start({
            --             name = "vtsls",
            --             cmd = { "vtsls", "--stdio" }, -- Убедитесь, что бинарник vtsls доступен в PATH
            --             root_dir = root_dir,
            --         }, { bufnr = args.buf })
            --     end,
            -- })

			-- Emmet (HTML/JSX abbreviations)
			vim.lsp.config("emmet_language_server", {
				capabilities = capabilities,
				filetypes = { "html", "css", "less", "scss", "javascriptreact", "typescriptreact" },
			})
			vim.lsp.enable("emmet_language_server")

			-- Python (навигация, автокомплит; типы через mypy в none-ls)
			vim.lsp.config("basedpyright", {
				capabilities = capabilities,
				settings = {
					basedpyright = {
						analysis = {
							typeCheckingMode = "off",
						},
					},
				},
			})
			vim.lsp.enable("basedpyright")

			-- Python linter/formatter (ruff)
			vim.lsp.config("ruff", {
				capabilities = capabilities,
				on_attach = function(client)
					client.server_capabilities.hoverProvider = false
				end,
			})
			vim.lsp.enable("ruff")

			-- SQL / CQL (Cassandra)
			vim.filetype.add({ extension = { cql = "cql" } })
			vim.lsp.config("sqlls", {
				capabilities = capabilities,
				filetypes = { "sql", "mysql", "cql" },
			})
			vim.lsp.enable("sqlls")

			-- CSS/LESS/SCSS
			vim.lsp.config("cssls", {
				capabilities = capabilities,
			})
			vim.lsp.enable("cssls")
		end,
	},

	-- Formatters/linters через none-ls
	{
		"nvimtools/none-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local null_ls = require("null-ls")

			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.prettier.with({
						filetypes = {
							"javascript",
							"javascriptreact",
							"typescript",
							"typescriptreact",
							"css",
							"less",
							"scss",
							"json",
							"jsonc",
												"markdown",
						},
					}),
					null_ls.builtins.diagnostics.stylelint,
					null_ls.builtins.formatting.stylelint,
				},
			})
		end,
	},
	-- Mypy (runs on save, no temp files)
	{
		"mfussenegger/nvim-lint",
		config = function()
			local mypy = require("lint").linters.mypy
			mypy.env = {
				LANG = "en_US.UTF-8",
				HOME = vim.env.HOME,
				VIRTUAL_ENV = vim.env.VIRTUAL_ENV or "",
			}

			require("lint").linters_by_ft = {
				python = { "mypy" },
			}

			vim.api.nvim_create_autocmd("BufWritePost", {
				group = vim.api.nvim_create_augroup("MypyOnSave", { clear = true }),
				pattern = { "*.py" },
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},
	-- Forgejo/Git
	{
		"AndreyGladkov/openinfg.nvim",
	},
}
