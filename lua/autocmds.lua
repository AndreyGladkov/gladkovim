-- Activate venv if pyproject.toml exists (for mypy, etc.)
local function activate_venv()
	local root = vim.fn.getcwd()
	if vim.fn.filereadable(root .. "/pyproject.toml") == 0 then
		return
	end

	local venv_path = root .. "/.venv"
	if vim.fn.isdirectory(venv_path) == 0 then
		venv_path = root .. "/venv"
	end
	if vim.fn.isdirectory(venv_path) == 0 then
		return
	end

	vim.env.VIRTUAL_ENV = venv_path
	vim.env.PATH = venv_path .. "/bin:" .. vim.env.PATH
end

activate_venv()

-- Format buffer with a specific LSP client.
-- No-op (no error) when the client isn't attached yet, e.g. right after opening
-- a file before LSP has finished attaching. Prevents the
-- "[LSP] Format request failed, no matching language servers." notification.
local function format_with_client(bufnr, client_name, timeout_ms)
	local attached = vim.tbl_filter(function(client)
		return client.name == client_name
	end, vim.lsp.get_clients({ bufnr = bufnr }))
	if #attached == 0 then
		return
	end
	vim.lsp.buf.format({
		bufnr = bufnr,
		timeout_ms = timeout_ms,
		filter = function(client)
			return client.name == client_name
		end,
	})
end

-- Show recent files on startup (only when no arguments passed)
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() == 0 then
            Snacks.picker.files()
		end
	end,
})

local augroup = vim.api.nvim_create_augroup("EslintPrettierOnSave", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.json", "*.jsonc" },
	callback = function(args)
		local ft = vim.bo[args.buf].filetype

		-- For JSON/JSONC: just format via prettier, no eslint
		if ft == "json" or ft == "jsonc" then
			format_with_client(args.buf, "null-ls", 5000)
			return
		end

		-- For JS/TS: eslint + prettier
		pcall(vim.cmd, "EslintFixAll")

		format_with_client(args.buf, "null-ls", 2000)
	end,
})

local ruff_augroup = vim.api.nvim_create_augroup("RuffOnSave", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = ruff_augroup,
	pattern = { "*.py" },
	callback = function(args)
		format_with_client(args.buf, "ruff", 2000)
	end,
})

local stylelint_augroup = vim.api.nvim_create_augroup("StylelintOnSave", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = stylelint_augroup,
	pattern = { "*.css", "*.less", "*.scss" },
	callback = function(args)
		format_with_client(args.buf, "null-ls", 2000)
	end,
})

local markdown_augroup = vim.api.nvim_create_augroup("MarkdownOnSave", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = markdown_augroup,
	pattern = { "*.md" },
	callback = function(args)
		format_with_client(args.buf, "null-ls", 2000)
	end,
})
