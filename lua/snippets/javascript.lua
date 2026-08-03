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
	-- Console.log
	s(
		"cl",
		fmta("console.log(<log>)<rest>", {
			log = i(1, "value"),
			rest = i(0),
		})
	),

	-- Console.error
	s(
		"ce",
		fmta("console.error(<log>)<rest>", {
			log = i(1, "error"),
			rest = i(0),
		})
	),

	-- Switch statement
	s(
		"switch",
		fmta(
			[[switch (<expr>) {
	case <case1>:
		<action1>
		break;
	case <case2>:
		<action2>
		break;
	default:
		<default>
		break;
}<rest>]],
			{
				expr = i(1, "value"),
				case1 = i(2, "case1"),
				action1 = i(3),
				case2 = i(4, "case2"),
				action2 = i(5),
				default = i(6),
				rest = i(0),
			}
		)
	),

	-- Try/catch
	s(
		"try",
		fmta(
			[[try {
	<try_body>
} catch (<error>) {
	<catch_body>
}<rest>]],
			{
				try_body = i(1),
				error = i(2, "err"),
				catch_body = i(3),
				rest = i(0),
			}
		)
	),

	-- Try/catch/finally
	s(
		"tryf",
		fmta(
			[[try {
	<try_body>
} catch (<error>) {
	<catch_body>
} finally {
	<finally_body>
}<rest>]],
			{
				try_body = i(1),
				error = i(2, "err"),
				catch_body = i(3),
				finally_body = i(4),
				rest = i(0),
			}
		)
	),

	-- If statement
	s(
		"if",
		fmta(
			[[if (<condition>) {
	<body>
}<rest>]],
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
			[[if (<condition>) {
	<if_body>
} else {
	<else_body>
}<rest>]],
			{
				condition = i(1, "condition"),
				if_body = i(2),
				else_body = i(3),
				rest = i(0),
			}
		)
	),

	-- For loop
	s(
		"for",
		fmta("for (let <i> = 0; <i> << <len>; <i>++) {\n\t<body>\n}<rest>", {
			i = i(1, "i"),
			len = i(2, "length"),
			body = i(3),
			rest = i(0),
		})
	),

	-- For...of loop
	s(
		"forof",
		fmta("for (const <item> of <iterable>) {\n\t<body>\n}<rest>", {
			item = i(1, "item"),
			iterable = i(2, "array"),
			body = i(3),
			rest = i(0),
		})
	),

	-- For...in loop
	s(
		"forin",
		fmta("for (const <key> in <object>) {\n\t<body>\n}<rest>", {
			key = i(1, "key"),
			object = i(2, "obj"),
			body = i(3),
			rest = i(0),
		})
	),

	-- Arrow function
	s(
		"af",
		fmta("const <name> = (<params>) =>> {\n\t<body>\n}<rest>", {
			name = i(1, "fn"),
			params = i(2, ""),
			body = i(3),
			rest = i(0),
		})
	),

	-- Function declaration
	s(
		"fun",
		fmta("function <name>(<params>) {\n\t<body>\n}<rest>", {
			name = i(1, "name"),
			params = i(2, ""),
			body = i(3),
			rest = i(0),
		})
	),

	-- export default
	s(
		"expd",
		fmta("export default <name>", {
			name = i(1, "Component"),
		})
	),

	-- export const
	s(
		"expc",
		fmta("export const <name> = <value>;<rest>", {
			name = i(1, "name"),
			value = i(2, "value"),
			rest = i(0),
		})
	),

	-- import
	s(
		"im",
		fmta("import <what> from '<from>';<rest>", {
			what = i(1, "something"),
			from = i(2, "module"),
			rest = i(0),
		})
	),

	-- import { }
	s(
		"imb",
		fmta("import { <what> } from '<from>';<rest>", {
			what = i(1, "something"),
			from = i(2, "module"),
			rest = i(0),
		})
	),

	-- Destructuring assignment
	s(
		"destr",
		fmta("const { <props> } = <source>;<rest>", {
			props = i(1, "prop1, prop2"),
			source = i(2, "obj"),
			rest = i(0),
		})
	),

	-- Array destructuring
	s(
		"desta",
		fmta("const [ <items> ] = <source>;<rest>", {
			items = i(1, "item1, item2"),
			source = i(2, "array"),
			rest = i(0),
		})
	),

	-- Promise
	s(
		"prom",
		fmta(
			[[new Promise((resolve, reject) =>> {
	<body>
})<rest>]],
			{
				body = i(1),
				rest = i(0),
			}
		)
	),

	-- async function
	s(
		"afun",
		fmta("async function <name>(<params>) {\n\t<body>\n}<rest>", {
			name = i(1, "name"),
			params = i(2, ""),
			body = i(3),
			rest = i(0),
		})
	),

	-- async arrow function
	s(
		"aaf",
		fmta("const <name> = async (<params>) =>> {\n\t<body>\n}<rest>", {
			name = i(1, "fn"),
			params = i(2, ""),
			body = i(3),
			rest = i(0),
		})
	),

	-- useEffect (React)
	s(
		"uef",
		fmta(
			[[useEffect(() =>> {
	<body>
}, [<deps>])<rest>]],
			{
				body = i(1),
				deps = i(2),
				rest = i(0),
			}
		)
	),

	-- useState (React)
	s(
		"ust",
		fmta("const [<state>, set<State>] = useState(<initial>);<rest>", {
			state = i(1, "state"),
			State = f(function(args)
				return args[1][1]:gsub("^%l", string.upper)
			end, { 1 }),
			initial = i(2),
			rest = i(0),
		})
	),

	-- useState with type (React TS)
--	s(
--		"ustt",
--		fmta("const [<state>, set<State>] = useState<(<Type>)>(<initial>);<rest>", {
--			state = i(1, "state"),
--			State = f(function(args)
--				return args[1][1]:gsub("^%l", string.upper)
--			end, { 1 }),
--			Type = i(2, "Type"),
--			initial = i(3),
--			rest = i(0),
--		})
--	),

	-- useRef (React)
-- 	s(
-- 		"uref",
-- 		fmta("const <ref> = useRef<<Type>>(<initial>);<rest>", {
-- 			ref = i(1, "ref"),
-- 			Type = i(2, "HTMLDivElement"),
-- 			initial = i(3, "null"),
-- 			rest = i(0),
-- 		})
-- 	),

	-- useCallback (React)
	s(
		"ucb",
		fmta(
			[[const <name> = useCallback((<params>) =>> {
	<body>
}, [<deps>]);<rest>]],
			{
				name = i(1, "callback"),
				params = i(2),
				body = i(3),
				deps = i(4),
				rest = i(0),
			}
		)
	),

	-- useMemo (React)
	s(
		"umm",
		fmta(
			[[const <name> = useMemo(() =>> {
	<body>
}, [<deps>]);<rest>]],
			{
				name = i(1, "memoized"),
				body = i(2),
				deps = i(3),
				rest = i(0),
			}
		)
	),

	-- TypeScript interface
	s(
		"int",
		fmta(
			[[interface <name> {
	<props>
}<rest>]],
			{
				name = i(1, "Props"),
				props = i(2),
				rest = i(0),
			}
		)
	),

	-- TypeScript type
	s(
		"type",
		fmta("type <name> = <definition>;<rest>", {
			name = i(1, "TypeName"),
			definition = i(2, "string"),
			rest = i(0),
		})
	),

	-- Ternary
	s(
		"tern",
		fmta("<cond> ? <if_true> : <if_false><rest>", {
			cond = i(1, "condition"),
			if_true = i(2, "value1"),
			if_false = i(3, "value2"),
			rest = i(0),
		})
	),

	-- Optional chaining
	s(
		"opt",
		fmta("<obj>?.<prop><rest>", {
			obj = i(1, "obj"),
			prop = i(2, "property"),
			rest = i(0),
		})
	),

	-- Nullish coalescing
	s(
		"nullc",
		fmta("<value> ?? <default><rest>", {
			value = i(1, "value"),
			default = i(2, "defaultValue"),
			rest = i(0),
		})
	),

	-- setTimeout
	s(
		"st",
		fmta(
			[[setTimeout(() =>> {
	<body>
}, <delay>);<rest>]],
			{
				body = i(1),
				delay = i(2, "1000"),
				rest = i(0),
			}
		)
	),

	-- setInterval
	s(
		"si",
		fmta(
			[[setInterval(() =>> {
	<body>
}, <delay>);<rest>]],
			{
				body = i(1),
				delay = i(2, "1000"),
				rest = i(0),
			}
		)
	),

	-- addEventListener
	s(
		"ael",
		fmta(
			[[<target>.addEventListener('<event>', (<args>) =>> {
	<body>
});<rest>]],
			{
				target = i(1, "element"),
				event = i(2, "click"),
				args = i(3, "e"),
				body = i(4),
				rest = i(0),
			}
		)
	),

	-- querySelector
	s(
		"qs",
		fmta("document.querySelector('<selector>')<rest>", {
			selector = i(1, ".class"),
			rest = i(0),
		})
	),

	-- querySelectorAll
	s(
		"qsa",
		fmta("document.querySelectorAll('<selector>')<rest>", {
			selector = i(1, ".class"),
			rest = i(0),
		})
	),

	-- fetch
	s(
		"fetch",
		fmta(
			[[fetch('<url>')
	.then(<res> =>> <res>.json())
	.then(<data> =>> {
		<body>
	})
	.catch(<err> =>> console.error(<err>));<rest>]],
			{
				url = i(1, "https://api.example.com/data"),
				res = i(2, "response"),
				data = i(3, "data"),
				body = i(4),
				err = i(5, "error"),
				rest = i(0),
			}
		)
	),

	-- async/await fetch
	s(
		"fetcha",
		fmta(
			[[try {
	const <res> = await fetch('<url>');
	const <data> = await <res>.json();
	<body>
} catch (<err>) {
	console.error(<err>);
}<rest>]],
			{
				res = i(1, "response"),
				url = i(2, "https://api.example.com/data"),
				data = i(3, "data"),
				body = i(4),
				err = i(5, "error"),
				rest = i(0),
			}
		)
	),

	-- class
	s(
		"class",
		fmta(
			[[class <name> {
	constructor(<params>) {
		<body>
	}
}<rest>]],
			{
				name = i(1, "ClassName"),
				params = i(2, ""),
				body = i(3),
				rest = i(0),
			}
		)
	),

	-- export class
	s(
		"expclass",
		fmta(
			[[export class <name> {
	constructor(<params>) {
		<body>
	}
}<rest>]],
			{
				name = i(1, "ClassName"),
				params = i(2, ""),
				body = i(3),
				rest = i(0),
			}
		)
	),

	-- While loop
	s(
		"while",
		fmta("while (<condition>) {\n\t<body>\n}<rest>", {
			condition = i(1, "condition"),
			body = i(2),
			rest = i(0),
		})
	),

	-- Do-while loop
	s(
		"dow",
		fmta(
			[[do {
	<body>
} while (<condition>);<rest>]],
			{
				body = i(1),
				condition = i(2, "condition"),
				rest = i(0),
			}
		)
	),

	-- Return statement
	s(
		"ret",
		fmta("return <value>;<rest>", {
			value = i(1),
			rest = i(0),
		})
	),

	-- Throw error
	s(
		"throw",
		fmta("throw new Error('<message>');<rest>", {
			message = i(1, "error message"),
			rest = i(0),
		})
	),

	-- Arrow function implicit return
	s(
		"afar",
		fmta("const <name> = (<params>) =>> <body>;<rest>", {
			name = i(1, "fn"),
			params = i(2, ""),
			body = i(3),
			rest = i(0),
		})
	),

	-- console.table
	s(
		"ct",
		fmta("console.table(<data>);<rest>", {
			data = i(1, "data"),
			rest = i(0),
		})
	),

	-- console.time / console.timeEnd
	s(
		"ctime",
		fmta(
			[[console.time('<label>');
<body>
console.timeEnd('<label>');<rest>]],
			{
				label = i(1, "timer"),
				body = i(2),
				rest = i(0),
			}
		)
	),

	-- JSON.parse
	s(
		"jsp",
		fmta("JSON.parse(<str>)<rest>", {
			str = i(1, "jsonString"),
			rest = i(0),
		})
	),

	-- JSON.stringify
	s(
		"jss",
		fmta("JSON.stringify(<obj>, null, <indent>)<rest>", {
			obj = i(1, "obj"),
			indent = i(2, "2"),
			rest = i(0),
		})
	),
}

