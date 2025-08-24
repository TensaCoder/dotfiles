-- _G.vim = vim or {}

local M = {}

function M.setup()
	local opts = { noremap = true, silent = true }
	-- Add your custom keymaps here
	-- For example:
	-- vim.keymap.set('n', '<leader>cc', ':SomeCommand<CR>', { desc = 'Run Some Command' })
	vim.keymap.set('n', '<Up>', ':resize -2<CR>', opts)
	vim.keymap.set('n', '<Down>', ':resize +2<CR>', opts)
	vim.keymap.set('n', '<Left>', ':vertical resize -2<CR>', opts)
	vim.keymap.set('n', '<Right>', ':vertical resize +2<CR>', opts)

	-- save file
	vim.keymap.set('n', '<C-s>', '<cmd> w <CR>', opts)

	-- quit file
	vim.keymap.set('n', '<C-q>', '<cmd> q <CR>', opts)

	-- Quit All (New Keybinding)
	vim.keymap.set('n', '<leader>qa', '<cmd>qall<CR>',
		{ desc = 'Quit all buffers and exit Neovim', noremap = true, silent = true })

	-- Buffers
	vim.keymap.set('n', '<leader><Tab>', ':bnext<CR>', opts)    -- Switch to the next buffer
	vim.keymap.set('n', '<leader><S-Tab>', ':bprevious<CR>', opts) -- Switch to the previous buffer

	vim.keymap.set('n', '<Leader>x', ':Bdelete!<CR>', opts)     -- Close/delete current buffer
	vim.keymap.set('n', '<Leader>b', '<cmd>enew<CR>', opts)     -- Create a new buffer

	-- Window management
	vim.keymap.set('n', '<leader>v', '<C-w>v', opts)   -- split window vertically
	vim.keymap.set('n', '<leader>h', '<C-w>s', opts)   -- split window horizontally
	vim.keymap.set('n', '<leader>se', '<C-w>=', opts)  -- make split windows equal width & height
	vim.keymap.set('n', '<leader>xs', ':close<CR>', opts) -- close current split window

	-- Tabs
	vim.keymap.set('n', '<leader>to', ':tabnew<CR>', opts) -- open new tab
	vim.keymap.set('n', '<leader>tx', ':tabclose<CR>', opts) -- close current tab
	vim.keymap.set('n', '<leader>tn', ':tabn<CR>', opts)  --  go to next tab
	vim.keymap.set('n', '<leader>tp', ':tabp<CR>', opts)  --  go to previous tab

	-- Toggle line wrapping
	vim.keymap.set('n', '<leader>lw', '<cmd>set wrap!<CR>', opts)

	-- For Advanced git search
	vim.keymap.set('n', '<leader>fi', '<cmd>AdvancedGitSearch<CR>', opts)

	-- -- Toggle diagnostics
	-- local diagnostics_active = true
	--
	-- vim.keymap.set('n', '<leader>do', function()
	-- 	diagnostics_active = not diagnostics_active
	--
	-- 	if diagnostics_active then
	-- 		vim.diagnostic.enable(0)
	-- 	else
	-- 		vim.diagnostic.disable(0)
	-- 	end
	-- end)

	-- Toggle diagnostics for all buffers
	local diagnostics_active = true

	vim.keymap.set('n', '<leader>db', function()
		diagnostics_active = not diagnostics_active

		if diagnostics_active then
			vim.diagnostic.enable(true, { bufnr = 0 }) -- Enable diagnostics for the current buffer
			print("🔵 [Buffer] LSP Diagnostics Enabled")
		else
			vim.diagnostic.enable(false, { bufnr = 0 }) -- Disable diagnostics for the current buffer
			print("🚫 [Buffer] LSP Diagnostics Disabled")
		end
	end, { desc = "Toggle LSP Diagnostics (Current Buffer)" })


	-- Toggle diagnostics globally
	local diagnostics_enabled = true

	vim.keymap.set("n", "<leader>dg", function()
		diagnostics_enabled = not diagnostics_enabled
		if diagnostics_enabled then
			vim.diagnostic.enable(true) -- Enable diagnostics globally
			print("✅ [Global] LSP Diagnostics Enabled")
		else
			vim.diagnostic.enable(false) -- Disable diagnostics globally
			print("❌ [Global] LSP Diagnostics Disabled")
		end
	end, { desc = "Toggle LSP Diagnostics (Global)" })

	-- Navbuddy keymaps
	vim.api.nvim_set_keymap('n', '<Leader>n', ':Navbuddy<CR>', { noremap = true, silent = true })

	-- Diagnostic keymaps
	vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
	vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
	vim.keymap.set('n', '<leader>dm', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
	-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
end

return M
