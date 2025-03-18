return {
	{
		"github/copilot.vim",
		lazy = false, -- Load Copilot immediately
		config = function()
			-- Disable default <Tab> mapping so we can define our own
			vim.g.copilot_no_tab_map = true

			-- Set better keybindings for Copilot suggestions
			vim.api.nvim_set_keymap("i", "<C-A>", 'copilot#Accept("\\<CR>")',
				{ silent = true, expr = true, replace_keycodes = false })                   -- Accept suggestion
			vim.api.nvim_set_keymap("i", "<C-]>", '<Plug>(copilot-accept-word)', { silent = true }) -- Accept next word
			vim.api.nvim_set_keymap("i", "<C-\\>", '<Plug>(copilot-accept-line)', { silent = true }) -- Accept next line
			vim.api.nvim_set_keymap("i", "<C-D>", '<Plug>(copilot-dismiss)', { silent = true }) -- Dismiss suggestion
			-- vim.api.nvim_set_keymap("i", "<M-]>", '<Plug>(copilot-next)', { silent = true }) -- Next suggestion
			-- vim.api.nvim_set_keymap("i", "<M-[>", '<Plug>(copilot-previous)', { silent = true }) -- Previous suggestion
			-- vim.api.nvim_set_keymap("i", "<M-\\>", '<Plug>(copilot-suggest)', { silent = true }) -- Manually request a suggestion

			vim.g.copilot_enabled = vim.g.copilot_enabled or false

			-- Toggle Copilot Function
			function ToggleCopilot()
				if vim.g.copilot_enabled then
					vim.g.copilot_enabled = false
					vim.cmd("Copilot disable")
					vim.notify("Copilot Disabled", vim.log.levels.WARN)
				else
					vim.g.copilot_enabled = true
					vim.cmd("Copilot enable")
					vim.notify("Copilot Enabled", vim.log.levels.INFO)
				end
			end

			-- Keybinding to Toggle Copilot
			vim.api.nvim_set_keymap("n", "<leader>at", ":lua ToggleCopilot()<CR>",
				{ noremap = true, silent = true, desc = "Copilot - Toggle Suggestions" })



			-- Improve Copilot's visual suggestion highlighting
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "*",
				callback = function()
					vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#555555", ctermfg = 8, force = true }) -- Dim gray for inline suggestions
				end,
			})
		end,
	},
}
