local M = {}

function M.setup()
  -- Add your custom options here
  -- For example:
  -- vim.opt.scrolloff = 8
  vim.opt_global.numberwidth = 2 -- set number column width to 2 {default 4}
  vim.opt_global.shiftwidth = 4  -- the number of spaces inserted for each indentation
  vim.opt_global.tabstop = 4     -- insert n spaces for a tab
  vim.opt_global.softtabstop = 4 -- Number of spaces that a tab counts for while performing editing operations
end

return M