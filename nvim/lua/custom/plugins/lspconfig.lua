return {
	-- Main LSP Configuration
	'neovim/nvim-lspconfig',
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		-- Automatically install LSPs and related tools to stdpath for Neovim
		{ 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
		'williamboman/mason-lspconfig.nvim',
		'WhoIsSethDaniel/mason-tool-installer.nvim',

		-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
		{ 'j-hui/fidget.nvim',       opts = {} },

		'hrsh7th/cmp-nvim-lsp',
	},
	config = function()
		vim.api.nvim_create_autocmd('LspAttach', {
			group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
			callback = function(event)
				-- NOTE: Remember that Lua is a real programming language, and as such it is possible
				-- to define small helper and utility functions so you don't have to repeat yourself.
				--
				-- In this case, we create a function that lets us more easily define mappings specific
				-- for LSP related items. It sets the mode, buffer and description for us each time.
				local map = function(keys, func, desc, mode)
					mode = mode or 'n'
					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
				end

				-- WARN: This is not Goto Definition, this is Goto Declaration.
				--  For example, in C this would take you to the header.
				map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

				-- Jump to the definition of the word under your cursor.
				--  This is where a variable was first declared, or where a function is defined, etc.
				--  To jump back, press <C-t>.
				map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

				-- Find references for the word under your cursor.
				map('gr', function()
					require('telescope.builtin').lsp_references({
						layout_strategy = 'vertical', -- Makes it easier to read file paths
						layout_config = {
							width = 0.9, -- Increase width for better visibility
							height = 0.9, -- Increase height for more results
							preview_cutoff = 1, -- Always show preview (even for small windows)
							preview_height = 0.6, -- More space for preview
						},
						sorting_strategy = "ascending", -- Show topmost results first
						-- path_display = { "tail" }, -- Ensure full paths are visible (no elision)
						-- previewer = true,
						fname_width = 92,
					})
				end, '[G]oto [R]eferences')

				map('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementations')

				-- Jump to the implementation of the word under your cursor.
				-- Fuzzy find all the symbols in your current document.
				--  Symbols are things like variables, functions, types, etc.
				map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

				-- Fuzzy find all the symbols in your current workspace.
				--  Similar to document symbols, except searches over your entire project.
				map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

				-- Rename the variable under your cursor.
				--  Most Language Servers support renaming across files, etc.
				map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

				-- Execute a code action, usually your cursor needs to be on top of an error
				-- or a suggestion from your LSP for this to activate.
				map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

				map("K", vim.lsp.buf.hover, "[LSP] Show Documentation")


				-- The following two autocommands are used to highlight references of the
				-- word under your cursor when your cursor rests there for a little while.
				--    See `:help CursorHold` for information about when this is executed
				--
				-- When you move your cursor, the highlights will be cleared (the second autocommand).
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
					local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
					vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd('LspDetach', {
						group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
						end,
					})
				end

				-- The following code creates a keymap to toggle inlay hints in your
				-- code, if the language server you are using supports them
				--
				-- This may be unwanted, since they displace some of your code
				if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
					map('<leader>th', function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
					end, '[T]oggle Inlay [H]ints')
				end
			end,
		})

		-- LSP servers and clients are able to communicate to each other what features they support.
		--  By default, Neovim doesn't support everything that is in the LSP specification.
		--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
		--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())


		-- Change the Diagnostic symbols in the sign column (gutter) added from josean lsp setup video
		-- (not in youtube nvim video)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end


		-- Enable the following language servers
		--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
		--
		--  Add any additional override configuration in the following tables. Available keys are:
		--  - cmd (table): Override the default command used to start the server
		--  - filetypes (table): Override the default list of associated filetypes for the server
		--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
		--  - settings (table): Override the default settings passed when initializing the server.
		--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/

		local servers = {
			-- C++/C
			clangd = {
				cmd = { 'clangd' },
				filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
				root_dir = require('lspconfig.util').root_pattern('compile_commands.json', 'compile_flags.txt', '.git'),
				settings = {
					clangd = {
						fallbackFlags = { '-std=c++17' },
					},
				},
				capabilities = vim.tbl_deep_extend('force', capabilities, { offsetEncoding = { 'utf-16' }, }),
			},

			-- Go
			gopls = {
				capabilities = capabilities,
				cmd = { 'gopls' },
				filetypes = { 'go', 'gomod' },
				root_dir = require('lspconfig.util').root_pattern('go.work', 'go.mod', '.git'),
				settings = {
					gopls = {
						analyses = {
							unusedparams = true,
						},
						staticcheck = true,
					},
				},
			},

			-- Python
			pyright = {
				capabilities = capabilities,
				cmd = { 'pyright-langserver', '--stdio' },
				filetypes = { 'python' },
				root_dir = require('lspconfig.util').root_pattern('.git', 'pyrightconfig.json'),
				settings = {
					python = {
						analysis = {
							typeCheckingMode = 'off', -- Set to "basic" or "strict" for stricter type checking
							autoSearchPaths = true,
							diagnosticMode = 'workspace',
							useLibraryCodeForTypes = true,
						},
					},
				},
			},

			-- JavaScript / TypeScript
			ts_ls = {
				capabilities = capabilities,
				cmd = { 'typescript-language-server', '--stdio' },
				filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'json' },
				root_dir = require('lspconfig.util').root_pattern('package.json', 'tsconfig.json', 'jsconfig.json',
					'.git'),
				settings = {
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = 'all',
							includeInlayFunctionLikeReturnTypeHints = true,
						},
					},
					javascript = {
						inlayHints = {
							includeInlayParameterNameHints = 'all',
							includeInlayFunctionLikeReturnTypeHints = true,
						},
					},
				},
				init_options = {
					preferences = {
						disableSuggestions = true,                              -- Helps reduce unnecessary LSP queries
						ignoredRootPaths = { "**/build/**", "**/dist/**", "**/node_modules/**" }, -- Ignore build directories
						exclude = { "build", "dist", "node_modules" },          -- Exclude files from being processed
					},
				},
			},

			-- Lua (already configured, but I'll include optimizations)
			lua_ls = {
				capabilities = capabilities,
				settings = {
					Lua = {
						completion = {
							callSnippet = 'Replace',
						},
						diagnostics = {
							disable = { 'missing-fields' },
						},
						workspace = {
							library = {
								vim.fn.expand '$VIMRUNTIME/lua',
								vim.fn.stdpath 'config' .. '/lua',
							},
						},
						telemetry = {
							enable = false,
						},
					},
				},
			},

			-- Terraform
			terraformls = {
				capabilities = capabilities,
				cmd = { 'terraform-ls', 'serve' },
				filetypes = { 'terraform', 'tf' },
				root_dir = require('lspconfig.util').root_pattern('.terraform', '.git'),
			},

			-- SQL
			sqlls = {
				capabilities = capabilities,
				cmd = { 'sql-language-server', 'up', '--method', 'stdio' },
				filetypes = { 'sql' },
				root_dir = require('lspconfig.util').root_pattern '.git',
				settings = {
					sql = {
						lint = {
							rules = {
								columnOrdering = true,
								upperCaseKeywords = true,
								semicolonNewline = true,
							},
						},
					},
				},
			},

			-- Dockerfile
			dockerls = {
				capabilities = capabilities,
				cmd = { 'docker-langserver', '--stdio' },
				filetypes = { 'dockerfile' },
				root_dir = require('lspconfig.util').root_pattern '.git',
			},

			-- YAML
			yamlls = {
				capabilities = capabilities,
				cmd = { 'yaml-language-server', '--stdio' },
				filetypes = { 'yaml', 'yml' },
				root_dir = require('lspconfig.util').root_pattern '.git',
				settings = {
					yaml = {
						schemas = {
							['http://json.schemastore.org/github-workflow'] = '.github/workflows/*',
							['http://json.schemastore.org/github-action'] = '.github/action.{yml,yaml}',
						},
					},
				},
			},

			-- HTML
			html = {
				capabilities = capabilities,
				cmd = { 'vscode-html-language-server', '--stdio' },
				filetypes = { 'html' },
				root_dir = require('lspconfig.util').root_pattern '.git',
				settings = {
					html = {
						format = {
							wrapLineLength = 120,
							wrapAttributes = 'auto',
						},
					},
				},
			},

			-- CSS
			cssls = {
				capabilities = capabilities,
				cmd = { 'vscode-css-language-server', '--stdio' },
				filetypes = { 'css', 'scss', 'less' },
				root_dir = require('lspconfig.util').root_pattern '.git',
			},

			-- GraphQL
			graphql = {
				capabilities = capabilities,
				cmd = { 'graphql-lsp', 'server', '-m', 'stream' },
				filetypes = { 'graphql'},
				root_dir = require('lspconfig.util').root_pattern('.git', 'graphql.config.*'),
			},

			---- Groovy
			-- groovyls = {
			--  cmd = { 'java', '-jar', '/path/to/groovy-language-server-all.jar' },
			--  filetypes = { 'groovy' },
			--  root_dir = require('lspconfig.util').root_pattern('.git', 'build.gradle'),
			-- },

			-- Markdown
			marksman = {
				capabilities = capabilities,
				cmd = { 'marksman', 'server' },
				filetypes = { 'markdown' },
				root_dir = require('lspconfig.util').root_pattern '.git',
			},
		}
		-- Ensure the servers and tools above are installed
		--  To check the current status of installed tools and/or manually install
		--  other tools, you can run
		--    :Mason
		--
		--  You can press `g?` for help in this menu.
		require('mason').setup()

		-- You can add other tools here that you want Mason to install
		-- for you, so that they are available from within Neovim.
		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, {
			'stylua', -- Used to format Lua code
		})
		-- require('mason-tool-installer').setup { ensure_installed = ensure_installed }

		require('mason-lspconfig').setup {
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					-- This handles overriding only values explicitly passed
					-- by the server configuration above. Useful when disabling
					-- certain features of an LSP (for example, turning off formatting for ts_ls)
					server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
					require('lspconfig')[server_name].setup(server)
				end,
			},
		}
	end,
}
