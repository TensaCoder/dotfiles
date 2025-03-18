-- Easily comment visual regions/lines
return {
  'numToStr/Comment.nvim',
  opts = {},
  config = function()
    require('Comment').setup() -- Ensure Comment.nvim is properly initialized

    local opts = { noremap = true, silent = true }
    local api = require('Comment.api')

    -- Normal mode
    vim.keymap.set('n', '<C-_>', api.toggle.linewise.current, opts)  -- Works on most keyboards
    -- vim.keymap.set('n', '<C-c>', api.toggle.linewise.current, opts)  -- Alternative
    vim.keymap.set('n', '<C-/>', api.toggle.linewise.current, opts)  -- May not work on macOS

    -- Visual mode
    vim.keymap.set('v', '<C-_>', "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", opts)
    -- vim.keymap.set('v', '<C-c>', "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", opts)
    vim.keymap.set('v', '<C-/>', "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", opts)
  end,
}

