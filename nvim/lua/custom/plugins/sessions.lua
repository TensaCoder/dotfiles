return {
	'rmagatti/auto-session',
	lazy = false,
	auto_save = true,    -- Enable auto-saving session on exit
	auto_restore = true, -- Restore session on startup
	-- Suppress session saving only when Neovim is opened in these exact directories
	suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },

	-- Store all session files in a custom directory
	auto_session_root_dir = vim.fn.expand("~/Temp/NvimSession"),

	keys = {
		-- Will use Telescope if installed or a vim.ui.select picker otherwise
		{ '<leader>wr', '<cmd>SessionSearch<CR>',         desc = 'Session search' },
		{ '<leader>we', '<cmd>SessionSave<CR>',           desc = 'Save session' },
		{ '<leader>wa', '<cmd>SessionToggleAutoSave<CR>', desc = 'Toggle autosave' },
	},

	---enables autocomplete for opts
	---@module "auto-session"
	---@type AutoSession.Config
	opts = {
		-- ⚠️ This will only work if Telescope.nvim is installed
		-- The following are already the default values, no need to provide them if these are already the settings you want.
		session_lens = {
			-- If load_on_setup is false, make sure you use `:SessionSearch` to open the picker as it will initialize everything first
			load_on_setup = true,
			previewer = false,
			-- Incase needed in the future
			-- mappings = {
			-- 	-- Mode can be a string or a table, e.g. {"i", "n"} for both insert and normal mode
			-- 	delete_session = { "i", "<C-D>" },
			-- 	alternate_session = { "i", "<C-S>" },
			-- 	copy_session = { "i", "<C-Y>" },
			-- },
			-- Can also set some Telescope picker options
			-- For all options, see: https://github.com/nvim-telescope/telescope.nvim/blob/master/doc/telescope.txt#L112
			theme_conf = {
				border = true,
				-- layout_config = {
				--   width = 0.8, -- Can set width and height as percent of window
				--   height = 0.5,
				-- },
			},
		},
	}
}
