local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

return {
	-- Print
	s(
		"pr",
		fmta("print(<value>)<rest>", {
			value = i(1, "value"),
			rest = i(0),
		})
	),

	-- If statement
	s(
		"if",
		fmta(
			[[if <condition>:
	<body>
<rest>]],
			{
				condition = i(1, "condition"),
				body = i(2),
				rest = i(0),
			}
		)
	),

	-- If/else
	s(
		"ife",
		fmta(
			[[if <condition>:
	<if_body>
else:
	<else_body>
<rest>]],
			{
				condition = i(1, "condition"),
				if_body = i(2),
				else_body = i(3),
				rest = i(0),
			}
		)
	),

	-- If/elif/else
	s(
		"ifel",
		fmta(
			[[if <condition1>:
	<if_body>
elif <condition2>:
	<elif_body>
else:
	<else_body>
<rest>]],
			{
				condition1 = i(1, "condition1"),
				if_body = i(2),
				condition2 = i(3, "condition2"),
				elif_body = i(4),
				else_body = i(5),
				rest = i(0),
			}
		)
	),

	-- For loop
	s(
		"for",
		fmta("for <item> in <iterable>:\n\t<body>\n<rest>", {
			item = i(1, "item"),
			iterable = i(2, "items"),
			body = i(3),
			rest = i(0),
		})
	),

	-- For loop with range
	s(
		"forr",
		fmta("for <i> in range(<start>, <last>):\n\t<body>\n<rest>", {
			i = i(1, "i"),
			start = i(2, "0"),
			last = i(3, "n"),
			body = i(4),
			rest = i(0),
		})
	),

	-- While loop
	s(
		"while",
		fmta("while <condition>:\n\t<body>\n<rest>", {
			condition = i(1, "condition"),
			body = i(2),
			rest = i(0),
		})
	),

	-- Try/except
	s(
		"try",
		fmta(
			[[try:
	<try_body>
except <error> as <err>:
	<except_body>
<rest>]],
			{
				try_body = i(1),
				error = i(2, "Exception"),
				err = i(3, "e"),
				except_body = i(4),
				rest = i(0),
			}
		)
	),

	-- Try/except/else/finally
	s(
		"tryf",
		fmta(
			[[try:
	<try_body>
except <error> as <err>:
	<except_body>
else:
	<else_body>
finally:
	<finally_body>
<rest>]],
			{
				try_body = i(1),
				error = i(2, "Exception"),
				err = i(3, "e"),
				except_body = i(4),
				else_body = i(5),
				finally_body = i(6),
				rest = i(0),
			}
		)
	),

	-- Function definition
	s(
		"def",
		fmta(
			[[def <name>(<params>):
	"""
	<docstring>
	"""
	<body>
<rest>]],
			{
				name = i(1, "function_name"),
				params = i(2, ""),
				docstring = i(3, "Description"),
				body = i(4),
				rest = i(0),
			}
		)
	),

	-- Async function
	s(
		"adef",
		fmta(
			[[async def <name>(<params>):
	"""
	<docstring>
	"""
	<body>
<rest>]],
			{
				name = i(1, "function_name"),
				params = i(2, ""),
				docstring = i(3, "Description"),
				body = i(4),
				rest = i(0),
			}
		)
	),

	-- Class definition
	s(
		"class",
		fmta(
			[[class <name>(<bases>):
	"""
	<docstring>
	"""

	def __init__(self, <params>):
		"""
		Initialize <name>.
		"""
		<body>

	<rest>]],
			{
				name = i(1, "ClassName"),
				bases = i(2, "object"),
				docstring = i(3, "Description of the class."),
				params = i(4, ""),
                body = i(4, ""),
				rest = i(0),
			}
		)
	),

	-- Main guard
	s(
		"main",
		fmta(
			[[if __name__ == '__main__':
	<main_body>
<rest>]],
			{
				main_body = i(1),
				rest = i(0),
			}
		)
	),

	-- Import
	s(
		"im",
		fmta("import <module><rest>", {
			module = i(1, "module_name"),
			rest = i(0),
		})
	),

	-- Import as
	s(
		"imas",
		fmta("import <module> as <alias><rest>", {
			module = i(1, "module_name"),
			alias = i(2, "alias"),
			rest = i(0),
		})
	),

	-- From import
	s(
		"from",
		fmta("from <module> import <name><rest>", {
			module = i(1, "module"),
			name = i(2, "name"),
			rest = i(0),
		})
	),

	-- Lambda
	s(
		"lam",
		fmta("lambda <params>: <body><rest>", {
			params = i(1, "x"),
			body = i(2, "x"),
			rest = i(0),
		})
	),

	-- List comprehension
	s(
		"lc",
		fmta("[<expr> for <item> in <iterable>]<rest>", {
			expr = i(1, "item"),
			item = i(2, "item"),
			iterable = i(3, "items"),
			rest = i(0),
		})
	),

	-- Dict comprehension
	s(
		"dc",
		fmta("{<key>: <value> for <item> in <iterable>}<rest>", {
			key = i(1, "k"),
			value = i(2, "v"),
			item = i(3, "item"),
			iterable = i(4, "items"),
			rest = i(0),
		})
	),

	-- Decorator
	s(
		"dec",
		fmta(
			[[@<decorator>
def <name>(<params>):
	<body>
<rest>]],
			{
				decorator = i(1, "decorator_name"),
				name = i(2, "function_name"),
				params = i(3, ""),
				body = i(4),
				rest = i(0),
			}
		)
	),

	-- Property
	s(
		"prop",
		fmta(
			[[@property
def <name>(self):
	"""<docstring>"""
	return <value>
<rest>]],
			{
				name = i(1, "property_name"),
				docstring = i(2, "Property description."),
				value = i(3, "self._value"),
				rest = i(0),
			}
		)
	),

	-- Return
	s(
		"ret",
		fmta("return <value><rest>", {
			value = i(1),
			rest = i(0),
		})
	),

	-- Yield
	s(
		"yield",
		fmta("yield <value><rest>", {
			value = i(1),
			rest = i(0),
		})
	),

	-- Raise exception
	s(
		"raise",
		fmta("raise <Error>('<message>')<rest>", {
			Error = i(1, "ValueError"),
			message = i(2, "error message"),
			rest = i(0),
		})
	),

	-- With statement
	s(
		"with",
		fmta("with <context> as <alias>:\n\t<body>\n<rest>", {
			context = i(1, "open('file.txt')"),
			alias = i(2, "f"),
			body = i(3),
			rest = i(0),
		})
	),

	-- Open file
	s(
		"open",
		fmta("with open('<path>', '<mode>') as <alias>:\n\t<body>\n<rest>", {
			path = i(1, "file.txt"),
			mode = i(2, "r"),
			alias = i(3, "f"),
			body = i(4),
			rest = i(0),
		})
	),

	-- Enumerate
	s(
		"enum",
		fmta("for <i>, <item> in enumerate(<iterable>):\n\t<body>\n<rest>", {
			i = i(1, "i"),
			item = i(2, "item"),
			iterable = i(3, "items"),
			body = i(4),
			rest = i(0),
		})
	),

	-- Zip
	s(
		"zip",
		fmta("for <a>, <b> in zip(<list1>, <list2>):\n\t<body>\n<rest>", {
			a = i(1, "a"),
			b = i(2, "b"),
			list1 = i(3, "list1"),
			list2 = i(4, "list2"),
			body = i(5),
			rest = i(0),
		})
	),

	-- Assert
	s(
		"assert",
		fmta("assert <condition>, '<message>'<rest>", {
			condition = i(1, "condition"),
			message = i(2, "Assertion error"),
			rest = i(0),
		})
	),

	-- f-string
	s(
		"fstr",
		fmta("f'<text>{<var>}<text2>'<rest>", {
			text = i(1, ""),
			var = i(2, "variable"),
			text2 = i(3, ""),
			rest = i(0),
		})
	),

	-- Type hint
	s(
		"th",
		fmta("<var>: <type> = <value><rest>", {
			var = i(1, "variable"),
			type = i(2, "str"),
			value = i(3, "''"),
			rest = i(0),
		})
	),

	-- Dataclass
	s(
		"dataclass",
		fmta(
			[[@dataclass
class <name>:
	"""<docstring>"""

	<fields>

	<rest>]],
			{
				name = i(1, "ClassName"),
				docstring = i(2, "Description."),
				fields = i(3, "field1: str\n\tfield2: int = 0"),
				rest = i(0),
			}
		)
	),

	-- Pydantic model
	s(
		"pymodel",
		fmta(
			[[class <name>(BaseModel):
	"""<docstring>"""

	<fields>

	<rest>]],
			{
				name = i(1, "ModelName"),
				docstring = i(2, "Description."),
				fields = i(3, "field1: str\n\tfield2: int = 0"),
				rest = i(0),
			}
		)
	),

	-- FastAPI route
	s(
		"fapi",
		fmta(
			[[@router.<method>('<path>')
async def <name>(<params>):
	"""<docstring>"""
	<body>
	<rest>]],
			{
				method = i(1, "get"),
				path = i(2, "/"),
				name = i(3, "handler"),
				params = i(4, ""),
				docstring = i(5, "Description."),
				body = i(6),
				rest = i(0),
			}
		)
	),
}

