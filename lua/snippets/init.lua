local ls = require("luasnip")

-- Load JavaScript/TypeScript snippets for JS, TS, TSX, JSX files
local javascript_snippets = require("snippets.javascript")
ls.add_snippets("javascript", javascript_snippets)
ls.add_snippets("typescript", javascript_snippets)
ls.add_snippets("typescriptreact", javascript_snippets)
ls.add_snippets("javascriptreact", javascript_snippets)

-- Load Python snippets for Python files
local python_snippets = require("snippets.python")
ls.add_snippets("python", python_snippets)
