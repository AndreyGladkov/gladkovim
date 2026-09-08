return {
	-- PlantUML syntax highlighting
	{
		"aklt/plantuml-syntax",
		ft = { "plantuml" },
		config = function()
			vim.g.plantuml_executable_script = "plantuml"
		end,
	},
	{
		"weirongxu/plantuml-previewer.vim",
		dependencies = { "aklt/plantuml-syntax" },
		ft = { "plantuml" },
		config = function()
			vim.g.plantuml_previewer_plantuml_jar = vim.fn.expand("~/.local/share/plantuml/plantuml.jar")
			vim.g.plantuml_previewer_debug_enabled = 1

			-- Custom commands for export
			local function export(format)
				return function()
					local buf = vim.api.nvim_get_current_buf()
					local ft = vim.bo[buf].filetype
					if ft ~= "plantuml" then
						vim.notify("Not a PlantUML file", vim.log.levels.WARN)
						return
					end
					local file = vim.fn.expand("%:p")
					if file == "" then
						vim.notify("Save the file first", vim.log.levels.WARN)
						return
					end

					local outdir = vim.fn.fnamemodify(file, ":h")
					local jar = vim.g.plantuml_previewer_plantuml_jar
					local cmd

					-- PNG export options: high DPI + increased size limit
					local extra_args = {}
					local jvm_args = {}
					if format == "png" then
						table.insert(extra_args, "-Sdpi=192")
						table.insert(jvm_args, "-DPLANTUML_LIMIT_SIZE=16384")
					end

					if vim.fn.executable("plantuml") == 1 then
						cmd = { "plantuml", unpack(jvm_args), "-t" .. format, unpack(extra_args), "-o", outdir, file }
					elseif vim.fn.filereadable(jar) == 1 then
						cmd = {
							"java", unpack(jvm_args), "-jar", jar,
							"-t" .. format,
							unpack(extra_args),
							"-o", outdir,
							file,
						}
					else
						vim.notify(
							"plantuml not found. Install plantuml or place plantuml.jar at "
								.. jar,
							vim.log.levels.ERROR
						)
						return
					end

					vim.fn.jobstart(cmd, {
						on_exit = function(_, code)
							if code == 0 then
								local base = vim.fn.fnamemodify(file, ":t:r")
								local outfile = outdir .. "/" .. base .. "." .. format
								vim.notify("Exported: " .. outfile, vim.log.levels.INFO)
							else
								vim.notify(
									"PlantUML export failed (code " .. code .. ")",
									vim.log.levels.ERROR
								)
							end
						end,
					})
				end
			end

			vim.api.nvim_create_user_command("PlantUMLExportPNG", export("png"), {
				desc = "Export PlantUML diagram to PNG",
			})
			vim.api.nvim_create_user_command("PlantUMLExportSVG", export("svg"), {
				desc = "Export PlantUML diagram to SVG",
			})
			vim.api.nvim_create_user_command("PlantUMLExportTXT", export("txt"), {
				desc = "Export PlantUML diagram to ASCII text",
			})

			-- Filetype detection for .puml/.iuml lives in lua/filetypes.lua:
			-- registering it here could never work, since this plugin only
			-- loads once a buffer already has the plantuml filetype.

			-- Keybindings (only for plantuml buffers)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "plantuml",
				callback = function()
					local opts = { buffer = true, silent = true, desc = "PlantUML: Export PNG" }
					vim.keymap.set("n", "<leader>up", ":PlantUMLExportPNG<CR>", opts)
					opts.desc = "PlantUML: Export SVG"
					vim.keymap.set("n", "<leader>us", ":PlantUMLExportSVG<CR>", opts)
					opts.desc = "PlantUML: Export TXT"
					vim.keymap.set("n", "<leader>ut", ":PlantUMLExportTXT<CR>", opts)
				end,
			})
		end,
	},
}

