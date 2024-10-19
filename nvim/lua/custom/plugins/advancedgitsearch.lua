return {
  'aaronhallaert/advanced-git-search.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'tpope/vim-fugitive',
  },
  config = function()
    require('telescope').load_extension 'advanced_git_search'
  end,
}
