return {
	'nvimtools/none-ls.nvim',
	dependencies = {
		'nvimtools/none-ls-extras.nvim',
		'jayp0521/mason-null-ls.nvim', -- ensure dependencies are installed
	},
	config = function()
		local null_ls = require 'null-ls'
		local formatting = null_ls.builtins.formatting -- to setup formatters
		local diagnostics = null_ls.builtins.diagnostics -- to setup linters

		-- list of formatters & linters for mason to install
		require('mason-null-ls').setup {
			ensure_installed = {
				'clang-format', -- Formatter for C/C++
				'golangci-lint', -- Linter for Go
				'black', -- Formatter for Python
				-- 'ruff', -- Linter for Python
				'prettier', -- Formatter for JS/TS
				'eslint_d', -- Linter for JS/TS
				'stylua', -- Formatter for Lua
				'terraform_fmt', -- Formatter for Terraform
				'sqlfluff', -- Formatter for SQL
				'hadolint', -- Linter for Dockerfile
				'yamllint', -- Linter for YAML
				'markdownlint', -- Linter for Markdown
			},
			-- auto-install configured formatters & linters (with null-ls)
			automatic_installation = true,
		}

		local sources = {
			-- C/C++
			formatting.clang_format.with {
				extra_args = { "--style", "{BasedOnStyle: Google, IndentWidth: 4, TabWidth: 4, AccessModifierOffset: -4}" },
				filetypes = { 'c', 'cpp' },
			},

			-- Go
			diagnostics.golangci_lint,

			-- Python
			-- formatting.black.with {
			--   extra_args = { '--line-length', '88', '--skip-string-normalization' }, -- Keep strings unchanged
			-- },
			-- require 'none-ls.diagnostics.ruff', -- Fix for ruff

			-- JavaScript/TypeScript
			formatting.prettier.with {
				filetypes = { 'javascript', 'typescript', 'json', 'yaml', 'markdown' },
				extra_args = { '--single-quote', '--jsx-single-quote', '--tab-width', '4' }, -- Set tab width to 4
			},
			require 'none-ls.diagnostics.eslint_d',                              -- Fix for eslint_d

			-- Lua
			formatting.stylua.with {
				extra_args = { '--indent-width', '4', '--quote-style', 'single' }, -- Set indent width to 4
			},

			-- Terraform
			formatting.terraform_fmt,

			-- SQL
			formatting.sqlfluff.with {
				extra_args = { '--dialect', 'postgres', '--rules', 'L003,L010' }, -- Specify SQL dialect and rules
			},

			-- Dockerfile
			diagnostics.hadolint,

			-- YAML
			diagnostics.yamllint.with {
				extra_args = { '--strict' },
			},

			-- HTML
			formatting.prettier.with {
				filetypes = { 'html' },
				extra_args = { '--print-width', '100' }, -- Custom rule for HTML
			},

			-- CSS/SCSS/LESS
			formatting.prettier.with {
				filetypes = { 'css', 'scss', 'less' },
				extra_args = { '--single-quote', '--tab-width', '4' }, -- Set tab width to 4
			},

			-- -- GraphQL
			-- require 'none-ls.diagnostics.prettier', -- Fix for graphql_schema_linter

			-- Markdown
			diagnostics.markdownlint.with {
				extra_args = { '--config', '.markdownlint.json' }, -- Specify config file for markdownlint
			},
		}

		local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
		null_ls.setup {
			sources = sources,
			-- you can reuse a shared lspconfig on_attach callback here
			on_attach = function(client, bufnr)
				if client.supports_method 'textDocument/formatting' then
					vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
					vim.api.nvim_create_autocmd('BufWritePre', {
						group = augroup,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format { async = false }
						end,
					})
				end
			end,
		}

		-- Key mapping for formatting
		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format { async = true }
		end, { desc = '[F]ormat buffer' })
	end,
}
