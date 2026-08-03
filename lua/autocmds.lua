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

-- Show recent files on startup (only when no arguments passed)
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() == 0 then
            Snacks.picker.smart()
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
			vim.lsp.buf.format({
				bufnr = args.buf,
				timeout_ms = 5000,
				filter = function(client)
					return client.name == "null-ls"
				end,
			})
			return
		end

		-- For JS/TS: eslint + prettier
		pcall(vim.cmd, "EslintFixAll")

		vim.lsp.buf.format({
			bufnr = args.buf,
			timeout_ms = 2000,
			filter = function(client)
				return client.name == "null-ls"
			end,
		})
	end,
})

local ruff_augroup = vim.api.nvim_create_augroup("RuffOnSave", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = ruff_augroup,
	pattern = { "*.py" },
	callback = function(args)
		vim.lsp.buf.format({
			bufnr = args.buf,
			timeout_ms = 2000,
			filter = function(client)
				return client.name == "ruff"
			end,
		})
	end,
})

local stylelint_augroup = vim.api.nvim_create_augroup("StylelintOnSave", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = stylelint_augroup,
	pattern = { "*.css", "*.less", "*.scss" },
	callback = function(args)
		vim.lsp.buf.format({
			bufnr = args.buf,
			timeout_ms = 2000,
			filter = function(client)
				return client.name == "null-ls"
			end,
		})
	end,
})
