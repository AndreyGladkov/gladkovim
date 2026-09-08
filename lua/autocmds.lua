local util = require("util")

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

-- Show file picker on startup (only when no arguments passed)
vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("StartupPicker", { clear = true }),
	callback = function()
		if vim.fn.argc() == 0 and Snacks then
			Snacks.picker.files()
		end
	end,
})

-- Format on save. Each entry names the LSP client that owns formatting for
-- those files: prettier/stylelint are served by null-ls (none-ls), Python by
-- ruff's own server. `eslint` additionally runs EslintFixAll beforehand.
local format_on_save = {
	{ pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" }, client = "null-ls", timeout = 2000, eslint = true },
	{ pattern = { "*.json", "*.jsonc" }, client = "null-ls", timeout = 5000 },
	{ pattern = { "*.css", "*.less", "*.scss" }, client = "null-ls", timeout = 2000 },
	{ pattern = { "*.md" }, client = "null-ls", timeout = 2000 },
	{ pattern = { "*.py" }, client = "ruff", timeout = 2000 },
}

local format_group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })

for _, spec in ipairs(format_on_save) do
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = format_group,
		pattern = spec.pattern,
		callback = function(args)
			if spec.eslint then
				pcall(vim.cmd, "EslintFixAll")
			end
			util.format_with_client(args.buf, spec.client, spec.timeout)
		end,
	})
end
