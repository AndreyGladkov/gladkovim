return {
	"kenn7/vim-arsync",
    dependencies = { "prabirshrestha/async.vim" },
	init = function()
		vim.g.arsync_global_ignore = { ".git", "node_modules", ".DS_Store" }
	end,
}

