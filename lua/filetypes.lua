-- Filetype detection.
--
-- This has to run at startup rather than from a plugin's `config`: a plugin
-- lazy-loaded with `ft = { "plantuml" }` can never register the extension that
-- would trigger its own loader. Neovim does not detect .puml/.iuml on its own.
vim.filetype.add({
	extension = {
		puml = "plantuml",
		iuml = "plantuml",
		plantuml = "plantuml",
		cql = "cql",
		jsonc = "jsonc",
	},
})
