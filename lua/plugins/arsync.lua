return {
	"kenn7/vim-arsync",
	cmd = {
		"ARSync",
		"ARSyncList",
		"ARSyncUpload",
		"ARSyncDownload",
		"ARSyncDiff",
	},
	keys = {
		{ "<leader>ru", "<cmd>ARSyncUpload<CR>", desc = "ArSync: Upload" },
		{ "<leader>rd", "<cmd>ARSyncDownload<CR>", desc = "ArSync: Download" },
		{ "<leader>rl", "<cmd>ARSyncList<CR>", desc = "ArSync: List configs" },
		{ "<leader>rx", "<cmd>ARSyncDiff<CR>", desc = "ArSync: Diff" },
	},
	init = function()
		vim.g.arsync_global_ignore = { ".git", "node_modules", ".DS_Store" }
	end,
}

