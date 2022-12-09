-- https://github.com/wbthomason/packer.nvim#bootstrapping
local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
		vim.cmd [[packadd packer.nvim]]
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'

	-- THEME <3
	use({
		'catppuccin/nvim',
		requires = {
			'airblade/vim-gitgutter'
		},
		config = function()
			require("catppuccin").setup({
				integrations = {
					gitgutter = true, -- enable vim-gitgutter style
					dap = {
						enabled = true,
						enable_ui = true,
					}
				}
			})

			vim.cmd.colorscheme "catppuccin"
		end
	})

	-- Git
	use({
		'airblade/vim-gitgutter',
		config = function()
			vim.cmd("set updatetime=100")
		end
	})

	-- Statusline
	use({
		'nvim-lualine/lualine.nvim',
		config = function()
			require('lualine').setup {
				options = {
					icons_enabled = false,
					theme = "catppuccin",
					component_separators = { left = '', right = '' },
					section_separators = { left = '', right = '' },
				}
			}
		end
	})

	-- Preview markdown
	use({
		'ellisonleao/glow.nvim',
		config = function()
			vim.g.glow_use_pager = true
			vim.g.glow_border = "shadow"
			vim.keymap.set("n", "<leader>p", "<cmd>Glow<cr>")
		end
	})

	-- Mason as a package manager for LSPs etc.
	use({
		'williamboman/mason.nvim',
		requires = { { 'williamboman/mason-lspconfig.nvim' } },
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗"
					}
				}
			})
		end
	})

	use({
		'williamboman/mason-lspconfig.nvim',
		config = function()
			require("mason-lspconfig").setup({
				automatic_installation = true,
			})
		end
	})

	-- Completion
	use({
		'hrsh7th/nvim-cmp',
		requires = {
			{ 'hrsh7th/cmp-nvim-lsp' },
			{ 'hrsh7th/cmp-buffer' },
			{ 'hrsh7th/cmp-path' },
			{ 'hrsh7th/cmp-cmdline' },
			{ 'neovim/nvim-lspconfig' },
			{ 'L3MON4D3/LuaSnip' }
		},
		config = function()
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
		end
	})

	-- LSP
	use({
		'neovim/nvim-lspconfig',
		requires = {
			{ 'williamboman/mason.nvim' }
		},
		config = function()
			local lspconfig = require("lspconfig")
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

			lspconfig.gopls.setup {
				cmd = { "gopls", "serve" },
				on_attach = on_attach,
				settings = {
					gopls = {
						gofumpt = true,
					},
				},
				flags = lsp_flags,
			}

			lspconfig.golangci_lint_ls.setup {
				on_attach = on_attach,
				settings = {
					gopls = {
						gofumpt = true,
					},
				},
				flags = lsp_flags,
			}

			lspconfig.sumneko_lua.setup {
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

			lspconfig.tsserver.setup {
				on_attach = on_attach,
				flags = lsp_flags
			}

			lspconfig.tailwindcss.setup {
				on_attach = on_attach,
				flags = lsp_flags
			}

			lspconfig.vuels.setup {
				on_attach = on_attach,
				flags = lsp_flags
			}

			lspconfig.pyright.setup {
				on_attach = on_attach,
				flags = lsp_flags
			}

			lspconfig.texlab.setup {
				on_attach = on_attach,
				flags = lsp_flags
			}

			vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.formatting_sync()]]
		end
	})

	use({
		'nvim-treesitter/nvim-treesitter',
		run = ":TSUpdateSync"
	})

	-- Telescope
	use({
		'nvim-telescope/telescope.nvim',
		tag = '0.1.0',
		requires = {
			{ 'nvim-lua/plenary.nvim' },
			{ 'nvim-telescope/telescope-file-browser.nvim' },
			{ 'nvim-treesitter/nvim-treesitter' }
		},
		config = function()
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
		end
	})

	-- Debugging
	use({
		'mfussenegger/nvim-dap',
		requires = {
			{ 'rcarriga/nvim-dap-ui' },
			{ 'leoluz/nvim-dap-go' }
		},
		config = function()
			require('dap-go').setup()
			vim.keymap.set("n", "<F5>", ":lua require'dap'.continue()<CR>")
			vim.keymap.set("n", "<F3>", ":lua require'dap'.step_over()<CR>")
			vim.keymap.set("n", "<F2>", ":lua require'dap'.step_into()<CR>")
			vim.keymap.set("n", "<F12>", ":lua require'dap'.step_out()<CR>")
			vim.keymap.set("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>")
			vim.keymap.set("n", "<leader>B", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
			vim.keymap.set("n", "<leader>lp",
				":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>")
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
		end
	})

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require('packer').sync()
	end
end)
