local M = {}

--- Highlights alabaster doesn't set itself: a pure white background and a
--- window separator that is actually visible on it.
local alabaster_overrides = {
	Normal = { bg = "#FFFFFF" },
	WinSeparator = { fg = "#000000", bg = "NONE" },
}

--- Apply the default theme: light, no treesitter.
function M.alabaster()
	vim.cmd.colorscheme("alabaster")
	vim.opt.background = "light"
	for group, opts in pairs(alabaster_overrides) do
		vim.api.nvim_set_hl(0, group, opts)
	end
end

local treesitter_active = false

local function each_loaded_buf(fn)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			fn(buf)
		end
	end
end

--- Treesitter language for a buffer, or nil when no parser exists for it
--- (neo-tree, avante and other plugin buffers land here).
---@param buf integer
---@return string?
local function buf_lang(buf)
	local ft = vim.bo[buf].filetype
	if ft == "" then
		return nil
	end

	local lang = vim.treesitter.language.get_lang(ft) or ft
	if not vim.tbl_contains(require("nvim-treesitter.parsers").available_parsers(), lang) then
		return nil
	end
	return lang
end

--- Languages whose parser is being compiled right now. nvim-treesitter has no
--- concurrency guard of its own: two installs of one parser race on a shared
--- temp directory and both can fail, so this module is the only installer
--- (hence `auto_install = false` in the plugin spec).
local installing = {}

--- Start treesitter highlighting in a buffer, installing the parser if needed.
--- Compilation runs in the background with no completion callback, hence the poll.
---@param buf integer
local function start_in_buf(buf)
	local lang = buf_lang(buf)
	if not lang then
		return
	end

	if pcall(vim.treesitter.start, buf) then
		return
	end

	if not installing[lang] then
		installing[lang] = true
		vim.notify("treesitter: installing " .. lang .. " parser")
		require("nvim-treesitter.install").ensure_installed(lang)
	end

	local waited = 0
	local timer = vim.uv.new_timer()
	timer:start(
		2000,
		2000,
		vim.schedule_wrap(function()
			waited = waited + 2

			local done = not treesitter_active
				or not vim.api.nvim_buf_is_loaded(buf)
				or pcall(vim.treesitter.start, buf)

			if done or waited >= 180 then
				timer:stop()
				timer:close()
				installing[lang] = nil
				if not done then
					vim.notify(
						("treesitter: %s parser did not finish installing"):format(lang),
						vim.log.levels.WARN
					)
				end
			end
		end)
	)
end

local treesitter_group = nil

--- Toggle between alabaster (plain) and catppuccin + treesitter (rich).
function M.toggle()
	if treesitter_active then
		treesitter_active = false
		if treesitter_group then
			vim.api.nvim_del_augroup_by_id(treesitter_group)
			treesitter_group = nil
		end
		each_loaded_buf(function(buf)
			pcall(vim.treesitter.stop, buf)
		end)
		M.alabaster()
		vim.notify("alabaster restored")
		return
	end

	treesitter_active = true
	require("lazy").load({ plugins = { "catppuccin", "nvim-treesitter" } })
	vim.cmd.colorscheme("catppuccin")
	each_loaded_buf(start_in_buf)

	-- Buffers opened while the rich theme is active need highlighting too.
	treesitter_group = vim.api.nvim_create_augroup("ThemeTreesitter", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = treesitter_group,
		callback = function(args)
			start_in_buf(args.buf)
		end,
	})

	vim.notify("catppuccin + treesitter enabled")
end

return M
