return {
	'AckslD/nvim-neoclip.lua',
	dependencies = {
		{ 'nvim-telescope/telescope.nvim' },
		{ 'kkharji/sqlite.lua' },
	},
	-- TODO: Add saving of copied data across sessions even after you quit neovim and open it again
	config = function()
		-- Check if sqlite.lua is installed
		local has_sqlite, sqlite = pcall(require, "sqlite")

		if not has_sqlite then
			vim.notify("❌ Neoclip requires sqlite.lua, but it's missing!", vim.log.levels.ERROR)
			return
		end

		-- Ensure the database directory exists
		local db_path = vim.fn.stdpath("data") .. "/neoclip.sqlite3"
		local db_dir = vim.fn.fnamemodify(db_path, ":h")
		if vim.fn.isdirectory(db_dir) == 0 then
			vim.fn.mkdir(db_dir, "p")
		end


		require('neoclip').setup {
			history = 1000,
			enable_persistent_history = true,
			length_limit = 1048576,
			continuous_sync = true,
			db_path = db_path,
			filter = nil,
			preview = true,
			prompt = nil,
			default_register = '"',
			default_register_macros = 'q',
			enable_macro_history = true,
			content_spec_column = false,
			disable_keycodes_parsing = false,
			on_select = {
				move_to_front = false,
				close_telescope = true,
			},
			on_paste = {
				set_reg = false,
				move_to_front = false,
				close_telescope = true,
			},
			on_replay = {
				set_reg = false,
				move_to_front = false,
				close_telescope = true,
			},
			on_custom_action = {
				close_telescope = true,
			},
			keys = {
				telescope = {
					i = {
						select = '<cr>',
						paste = '<c-j>',
						paste_behind = '<c-k>',
						replay = '<c-q>', -- replay a macro
						delete = '<c-d>', -- delete an entry
						edit = '<c-e>', -- edit an entry
						custom = {},
					},
					n = {
						select = '<cr>',
						paste = 'p',
						--- It is possible to map to more than one key.
						-- paste = { 'p', '<c-p>' },
						paste_behind = 'P',
						replay = 'q',
						delete = 'd',
						edit = 'e',
						custom = {},
					},
				},
			},
		}

		vim.keymap.set('n', '<leader>o', '<cmd>Telescope neoclip<CR>', { desc = 'Telescope Neoclip' })
	end,
}
