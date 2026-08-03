local keymap = vim.keymap.set
local silent = { silent = true }

-- Explorer
keymap("n", "<C-e>", ":Neotree toggle<CR>", silent)

-- Buffer navigation
keymap("n", "<Tab>", ":BufferLineCycleNext<CR>", silent)
keymap("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", silent)
keymap("n", "<S-q>", ":bdelete<CR>", silent)

for i = 1, 9 do
	keymap("n", "<leader>" .. i, ":BufferLineGoToBuffer " .. i .. "<CR>", silent)
end

keymap("i", "jj", "<ESC>", silent)

-- Clipboard: Ctrl+C/V/X like in standard editors
keymap("v", "<C-c>", '"+y', silent) -- Copy in visual mode
keymap("v", "<C-x>", '"+x', silent) -- Cut in visual mode
keymap("i", "<C-v>", "<C-r>+", silent) -- Paste in insert mode

-- lsp
keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })

keymap("n", "gD", function()
	vim.lsp.buf.definition({
		on_list = function(list)
			if #list.items == 1 then
				local item = list.items[1]
				vim.cmd.edit(item.filename)
				vim.fn.setcursorcharpos(item.lnum, item.col)
			else
				vim.fn.setqflist(list.items)
				vim.cmd.copen()
			end
		end,
	})
end, { desc = "Go to Definition (all results)" })

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local opts = { buffer = args.buf }
		keymap("n", "gr", vim.lsp.buf.references, opts)

		keymap(
			"n",
			"<leader>ca",
			vim.lsp.buf.code_action,
			vim.tbl_extend("force", opts, { desc = "Code Action" })
		)

		keymap("n", "<leader>cr", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))

		keymap("n", "<leader>cF", function()
			vim.lsp.buf.code_action({
				apply = true,
			})
		end, vim.tbl_extend("force", opts, { desc = "Auto Fix" }))

		-- Show diagnostics floating popup on hover
		vim.api.nvim_create_autocmd("CursorHold", {
			buffer = args.buf,
			callback = function()
				vim.diagnostic.open_float({ scope = "cursor", focus = false })
			end,
		})
	end,
})

-- Show type info on hover
keymap("n", "<leader>ct", vim.lsp.buf.hover, { desc = "Show Type Info" })

-- Go to type definition
keymap("n", "<leader>cT", vim.lsp.buf.type_definition, { desc = "Go to Type Definition" })

-- Manually open diagnostics popup
keymap("n", "<leader>dd", function()
	vim.diagnostic.open_float({ scope = "cursor", focus = false })
end, { desc = "Line Diagnostics" })

-- Show file diagnostics in quickfix list
keymap("n", "<leader>cd", function()
	vim.diagnostic.setqflist({ open = true })
end, { desc = "File Diagnostics (Quickfix)" })

-- Git
keymap("n", "<Leader>gf", ":OpenInFGFile<CR>", { silent = true, noremap = true })
keymap("v", "<Leader>gf", ":OpenInFGFileLines<CR>", { silent = true, noremap = true })

-- Toggle catppuccin + treesitter / restore alabaster
local _catppuccin_active = false
keymap("n", "<leader>tt", function()
	if not _catppuccin_active then
		require("lazy").load({ plugins = { "catppuccin", "nvim-treesitter" } })
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(buf) then
				pcall(vim.treesitter.start, buf)
			end
		end
		vim.cmd.colorscheme("catppuccin")
		_catppuccin_active = true
		vim.notify("catppuccin + treesitter enabled")
	else
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(buf) then
				pcall(vim.treesitter.stop, buf)
			end
		end
		vim.cmd.colorscheme("alabaster")
		vim.opt.background = "light"
		vim.api.nvim_set_hl(0, "Normal", { bg = "#FFFFFF" })
		vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#000000", bg = "NONE" })
		_catppuccin_active = false
		vim.notify("alabaster restored")
	end
end, { desc = "Toggle catppuccin+treesitter / alabaster" })

-- Manual format via prettier (null-ls)
keymap("n", "<leader>cf", function()
	vim.lsp.buf.format({
		timeout_ms = 5000,
		filter = function(client)
			return client.name == "null-ls"
		end,
	})
end, { desc = "Format (Prettier)" })

-- Optional: Disable default space behavior in normal/visual mode to avoid conflicts
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })


