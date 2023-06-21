local tools = require("config.tools")

return {
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = true,
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		event = "VeryLazy",
		opts = {
			ensure_installed = tools.lsp,
		},
	},
	{
		"jay-babu/mason-null-ls.nvim",
		dependencies = { "williamboman/mason.nvim" },
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local mason_null_ls = require("mason-null-ls")

			local null_ls_tools = tools.linter
			for _, f in pairs(tools.formatter) do
				table.insert(null_ls_tools, f)
			end

			mason_null_ls.setup({
				ensure_installed = null_ls_tools,
				handlers = {},
			})
		end,
	},
	{
		"RubixDev/mason-update-all",
		dependencies = { "williamboman/mason.nvim" },
		cmd = { "MasonUpdateAll" },
		config = true,
	},
}
