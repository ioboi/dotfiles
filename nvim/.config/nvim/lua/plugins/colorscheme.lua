return {
	{
		"catppuccin/nvim",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
		dependencies = { "lewis6991/gitsigns.nvim" },
		opts = {
			integrations = {
				gitsigns = true, -- enable gitsigns style
				dap = {
					enabled = true,
					enable_ui = true,
				},
			},
		},
		config = function()
			-- load the colorscheme here
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
