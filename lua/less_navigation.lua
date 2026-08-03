local M = {}

--- Get the word under cursor, including the @ prefix for LESS variables
local function get_cursor_word()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	-- col is 0-indexed, vim.fn.col is 1-indexed

	-- Check if we're on an @variable
	local start = col
	while start > 0 and line:sub(start, start):match("[%w_-]") do
		start = start - 1
	end
	-- Include @ prefix if present
	if start > 0 and line:sub(start, start) == "@" then
		start = start - 1
	end

	local finish = col + 1
	while finish <= #line and line:sub(finish, finish):match("[%w_-]") do
		finish = finish + 1
	end

	local word = line:sub(start + 1, finish - 1)
	return word, start + 1, finish - 1
end

--- Get the import path under cursor (e.g., @import "path/to/file")
local function get_import_path()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-indexed

	-- Match @import, @use, @require patterns
	local import_patterns = {
		'@import%s+[\'"]([^\'"]+)[\'"]',
		'@import%s+url%([\'"]?([^\'")]+)[\'"]?%)',
		'@use%s+[\'"]([^\'"]+)[\'"]',
		'@require%s+[\'"]([^\'"]+)[\'"]',
	}

	for _, pattern in ipairs(import_patterns) do
		local match_start, _, path = line:find(pattern)
		if match_start and col >= match_start and col <= (match_start + #line:sub(match_start)) then
			return path
		end
	end

	-- Check if cursor is on a quoted string that looks like a path
	local quote_start, quote_end, path = line:find('[\'"]([^\'"]+)[\'"]')
	if quote_start and col > quote_start and col <= quote_end then
		return path
	end

	return nil
end

--- Resolve an import path to an actual file
local function resolve_import_path(import_path)
	local buf_dir = vim.fn.expand("%:p:h")
	local candidates = {}

	-- Try as-is
	table.insert(candidates, buf_dir .. "/" .. import_path)

	-- Try with common extensions
	for _, ext in ipairs({ ".less", ".css", ".scss" }) do
		table.insert(candidates, buf_dir .. "/" .. import_path .. ext)
	end

	-- Try with _ prefix (BEM/SMACSS convention)
	local basename = import_path:match("([^/]+)$")
	local dir = import_path:match("^(.*/)") or ""
	for _, ext in ipairs({ ".less", ".css", ".scss" }) do
		table.insert(candidates, buf_dir .. "/" .. dir .. "_" .. basename .. ext)
	end

	for _, candidate in ipairs(candidates) do
		if vim.fn.filereadable(candidate) == 1 then
			return candidate
		end
	end

	return nil
end

--- Go to definition of a LESS variable using ripgrep
local function goto_variable_definition(variable_name)
	-- Search for the variable definition: @var-name:
	local search_pattern = vim.fn.escape(variable_name, "-") .. "%s*:"
	local project_root = vim.fn.getcwd()

	local results = {}
	local handle = io.popen(
		"rg --line-number --column --no-heading --type-add 'style:*.less' --type-add 'style:*.css' --type-add 'style:*.scss' --type style -- "
			.. vim.fn.shellescape(search_pattern)
			.. " "
			.. vim.fn.shellescape(project_root)
			.. " 2>/dev/null"
	)

	if handle then
		for line in handle:lines() do
			local file, lnum, col, text = line:match("^(.+):(%d+):(%d+):(.*)$")
			if file and lnum then
				-- Skip the current line (where the variable is used)
				local current_file = vim.fn.expand("%:p")
				if not (file == current_file and tonumber(lnum) == vim.api.nvim_win_get_cursor(0)[1]) then
					table.insert(results, {
						filename = file,
						lnum = tonumber(lnum),
						col = tonumber(col),
						text = text,
					})
				end
			end
		end
		handle:close()
	end

	if #results == 0 then
		vim.notify("No definition found for " .. variable_name, vim.log.levels.INFO)
		return
	end

	if #results == 1 then
		vim.cmd.edit(results[1].filename)
		vim.fn.setcursorcharpos(results[1].lnum, results[1].col)
	else
		-- Show quickfix list for multiple results
		local qf_items = {}
		for _, r in ipairs(results) do
			table.insert(qf_items, {
				filename = r.filename,
				lnum = r.lnum,
				col = r.col,
				text = r.text,
			})
		end
		vim.fn.setqflist(qf_items)
		vim.cmd.copen()
	end
end

--- Go to file from @import statement
local function goto_import_file(import_path)
	local resolved = resolve_import_path(import_path)
	if resolved then
		vim.cmd.edit(resolved)
		return
	end

	-- Fallback: search for the file by basename
	local basename = import_path:match("([^/]+)$") or import_path
	local handle = io.popen("rg --files --glob '*" .. basename .. "*' " .. vim.fn.getcwd() .. " 2>/dev/null")
	if handle then
		local results = {}
		for line in handle:lines() do
			table.insert(results, line)
		end
		handle:close()

		if #results == 1 then
			vim.cmd.edit(results[1])
		elseif #results > 1 then
			local qf_items = {}
			for _, f in ipairs(results) do
				table.insert(qf_items, { filename = f, lnum = 1, col = 1, text = f })
			end
			vim.fn.setqflist(qf_items)
			vim.cmd.copen()
		else
			vim.notify("File not found: " .. import_path, vim.log.levels.WARN)
		end
	else
		vim.notify("File not found: " .. import_path, vim.log.levels.WARN)
	end
end

--- Main entry point: go to definition for LESS/CSS/SCSS files
function M.goto_definition()
	-- First try LSP
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	local has_lsp = #clients > 0

	if has_lsp then
		local params = vim.lsp.util.make_position_params(0, "utf-16")
		local results = {}

		for _, client in ipairs(clients) do
			if client.server_capabilities.definitionProvider then
				local resp = client:request_sync("textDocument/definition", params, 1000, 0)
				if resp and resp.result then
					local locations = resp.result
					if locations.uri then
						locations = { locations }
					end
					if locations.targetUri then
						locations = { locations }
					end
					if type(locations) == "table" then
						for _, loc in ipairs(locations) do
							local uri = loc.uri or loc.targetUri
							local range = loc.range or loc.targetSelectionRange
							if uri and range then
								table.insert(results, {
									filename = vim.uri_to_fname(uri),
									lnum = range.start.line + 1,
									col = range.start.character + 1,
								})
							end
						end
					end
				end
			end
		end

		if #results > 0 then
			vim.cmd.edit(results[1].filename)
			vim.fn.setcursorcharpos(results[1].lnum, results[1].col)
			return
		end
	end

	-- LSP didn't find anything, try custom navigation
	-- Check if cursor is on an import path
	local import_path = get_import_path()
	if import_path then
		goto_import_file(import_path)
		return
	end

	-- Check if cursor is on a variable
	local word = get_cursor_word()
	if word and word:match("^@[%w_-]+$") then
		goto_variable_definition(word)
		return
	end

	vim.notify("No definition found", vim.log.levels.INFO)
end

return M

