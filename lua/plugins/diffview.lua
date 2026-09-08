return {
	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose", "DiffviewToggleFiles" },
		opts = {
			view = {
				default = {
					layout = "diff1",
				},
			},
			file_panel = {
				width = 35,
				win_config = { position = "left" },
			},
		},
	},
}

