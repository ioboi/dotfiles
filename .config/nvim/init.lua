local Plug = vim.fn['plug#']
vim.call('plug#begin')
-- LSP stuff
Plug('williamboman/mason.nvim')
Plug('williamboman/mason-lspconfig.nvim')
Plug('neovim/nvim-lspconfig')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-path')
Plug('hrsh7th/cmp-cmdline')
Plug('hrsh7th/nvim-cmp')
Plug('L3MON4D3/LuaSnip')
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
-- THEME <3
Plug('catppuccin/nvim', { as = 'catppuccin' })
-- Telescope
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim', { tag = '0.1.0' })
Plug('nvim-lualine/lualine.nvim')
Plug('nvim-telescope/telescope-file-browser.nvim')
-- MD
Plug('ellisonleao/glow.nvim')
-- DAP
Plug('mfussenegger/nvim-dap')
Plug('rcarriga/nvim-dap-ui')
Plug('leoluz/nvim-dap-go')
vim.call('plug#end')

-- General configuration
vim.cmd.colorscheme "catppuccin"

require('lualine').setup {
	options = {
		icons_enabled = false,
		theme = "catppuccin",
		component_separators = { left = '', right = '' },
		section_separators = { left = '', right = '' },
	}
}

vim.o.ma = true
vim.o.mouse = 'a'
vim.o.cursorline = true -- enable cursorline
vim.o.nu = true -- enable line numbers

vim.o.tabstop = 4 -- tab 4 spaces
vim.o.shiftwidth = 4 -- indent 4 spaces
vim.o.softtabstop = 4

vim.o.autoread = true -- automatically reload buffer if file changes
vim.o.clipboard = "unnamedplus" -- use system clipboard
vim.o.scrolloff = 7 -- keep 7 lines above cursor when scrolling

vim.g.mapleader = " " -- set leader to space

-- glow
vim.g.glow_use_pager = true
vim.g.glow_border = "shadow"
vim.keymap.set("n", "<leader>p", "<cmd>Glow<cr>")

-- https://github.com/hrsh7th/nvim-cmp#recommended-configuration
local cmp = require 'cmp'
cmp.setup({
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	mapping = {
		['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
		['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
		['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
		['<C-e>'] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),
		-- Accept currently selected item. If none selected, `select` first item.
		-- Set `select` to `false` to only confirm explicitly selected items.
		['<CR>'] = cmp.mapping.confirm({ select = true }),
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' }, -- For luasnip users.
	}, {
		{ name = 'buffer' },
	})
})

-- mason
require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗"
		}
	}
})

require("mason-lspconfig").setup({
	automatic_installation = true,
})

-- https://github.com/neovim/nvim-lspconfig#suggested-configuration
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
	vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
	vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
	vim.keymap.set('n', '<space>wl', function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, bufopts)
	vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
	vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
	vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
	vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
	vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

local lsp_flags = {
	debounce_text_changes = 150,
}

require("lspconfig").gopls.setup {
	cmd = { "gopls", "serve" },
	on_attach = on_attach,
	settings = {
		gopls = {
			gofumpt = true,
		},
	},
	flags = lsp_flags,
}

require("lspconfig").golangci_lint_ls.setup {
	on_attach = on_attach,
	settings = {
		gopls = {
			gofumpt = true,
		},
	},
	flags = lsp_flags,
}

require("lspconfig").sumneko_lua.setup {
	on_attach = on_attach,
	settings = {
		Lua = {
			diagnostics = {
				globals = { 'vim' },
			},
		},
		telemetry = {
			enabled = false
		},
	},
	flags = lsp_flags
}

require("lspconfig").tsserver.setup {
	on_attach = on_attach,
	flags = lsp_flags
}

require("lspconfig").tailwindcss.setup {
	on_attach = on_attach,
	flags = lsp_flags
}

require("lspconfig").vuels.setup {
	on_attach = on_attach,
	flags = lsp_flags
}

require("lspconfig").pyright.setup {
	on_attach = on_attach,
	flags = lsp_flags
}

require("lspconfig").texlab.setup {
	on_attach = on_attach,
	flags = lsp_flags
}

-- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#neovim-imports
function go_org_imports(wait_ms)
	local params = vim.lsp.util.make_range_params()
	params.context = { only = { "source.organizeImports" } }
	local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
	for cid, res in pairs(result or {}) do
		for _, r in pairs(res.result or {}) do
			if r.edit then
				local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
				vim.lsp.util.apply_workspace_edit(r.edit, enc)
			end
		end
	end
end

vim.api.nvim_command("au BufWritePre *.go lua go_org_imports(1000)")
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.formatting_sync()]]

-- Telescope configuration https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#file-and-text-search-in-hidden-files-and-directories
local telescope = require("telescope")
local telescopeConfig = require("telescope.config")

-- Clone the default Telescope configuration
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) } -- will be table.unpack

-- I want to search in hidden/dot files.
table.insert(vimgrep_arguments, "--hidden")
-- I don't want to search in the `.git` directory.
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!**/.git/*")

telescope.setup({
	defaults = {
		-- `hidden = true` is not supported in text grep commands.
		vimgrep_arguments = vimgrep_arguments,
	},
	pickers = {
		find_files = {
			-- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
			find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
		},
	},
})

telescope.load_extension("file_browser")

local builtin = require('telescope.builtin')
vim.keymap.set("n", "<C-F>",
	"<cmd>Telescope current_buffer_fuzzy_find sorting_strategy=ascending prompt_position=top<CR>")
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', ":Telescope file_browser disable_devicons=true<CR>")
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- DAP DAP DAP
require('dap-go').setup()
vim.keymap.set("n", "<F5>", ":lua require'dap'.continue()<CR>")
vim.keymap.set("n", "<F3>", ":lua require'dap'.step_over()<CR>")
vim.keymap.set("n", "<F2>", ":lua require'dap'.step_into()<CR>")
vim.keymap.set("n", "<F12>", ":lua require'dap'.step_out()<CR>")
vim.keymap.set("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>")
vim.keymap.set("n", "<leader>B", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
vim.keymap.set("n", "<leader>lp", ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>")
vim.keymap.set("n", "<leader>dr", ":lua require'dap'.repl.open()<CR>")
vim.keymap.set("n", "<leader>dt", ":lua require'dap-go'.debug_test()<CR>")

require('dap-go').setup()
require("dapui").setup()

local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end
