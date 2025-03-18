return {
  {
    "AstroNvim/astrotheme",
    priority = 1000, -- Ensure it loads first
    config = function()
      require("astrotheme").setup {
        style = "dark", -- Set to "dark" or "light"
      }
      vim.cmd("colorscheme astrotheme")
    end,
  },
}

