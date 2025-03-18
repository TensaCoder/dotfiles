local M = {}

function M.setup()
	-- Add your custom options here
	-- For example:
	-- vim.opt.scrolloff = 8
	vim.opt_global.numberwidth = 2 -- set number column width to 2 {default 4}
	vim.opt_global.shiftwidth = 4 -- the number of spaces inserted for each indentatior
	vim.opt_global.tabstop = 4  -- insert n spaces for a tab
	vim.opt_global.softtabstop = 4 -- Number of spaces that a tab counts for while performing editing operations
	vim.opt.undolevels = 2000
	vim.o.winbar = "%=%{v:lua.require'nvim-navic'.get_location({ highlight = true, icons = true })}"
	-- Make <Tab> insert 4 spaces
	vim.api.nvim_set_keymap("i", "<Tab>", "    ", { noremap = true, silent = true })
end

return M
