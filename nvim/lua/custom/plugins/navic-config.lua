local navic = require("nvim-navic");

return {
	-- -- Setup winbar with lualine.nvim or feline.nvim
	-- require("lualine").setup({
	-- 	-- sections = {
	-- 	-- 	lualine_c = {
	-- 	-- 		{
	-- 	-- 			function()
	-- 	-- 				return navic.get_location()
	-- 	-- 			end,
	-- 	-- 			cond = function()
	-- 	-- 				return navic.is_available()
	-- 	-- 			end,
	-- 	-- 		},
	-- 	-- 	},
	-- 	-- },
	-- 	winbar = {
	-- 		lualine_c = {
	-- 			{
	-- 				function()
	-- 					return navic.get_location()
	-- 				end,
	-- 				cond = function()
	-- 					return navic.is_available()
	-- 				end,
	-- 			},
	-- 		},
	-- 	},
	-- })

	-- Feline winbar setup
	require('feline').winbar.setup({


		-- Setup nvim-navic
		navic.setup({
			icons = {
				File          = "󰈙 ",
				Module        = " ",
				Namespace     = "󰌗 ",
				Package       = " ",
				Class         = "󰌗 ",
				Method        = "󰆧 ",
				Property      = " ",
				Field         = " ",
				Constructor   = " ",
				Enum          = "󰕘",
				Interface     = "󰕘",
				Function      = "󰊕 ",
				Variable      = "󰆧 ",
				Constant      = "󰏿 ",
				String        = "󰀬 ",
				Number        = "󰎠 ",
				Boolean       = "◩ ",
				Array         = "󰅪 ",
				Object        = "󰅩 ",
				Key           = "󰌋 ",
				Null          = "󰟢 ",
				EnumMember    = " ",
				Struct        = "󰌗 ",
				Event         = " ",
				Operator      = "󰆕 ",
				TypeParameter = "󰊄 ",
			},
			lsp = {
				auto_attach = true, -- Automatically attach to LSP servers
			},
			highlight = true,
			separator = " > ",   -- Separator between symbols
			depth_limit = 0,     -- No limit on depth
			depth_limit_indicator = "..", -- Indicator for truncated depth
		}),

		components = {
			active = {
				{
					{
						provider = function()
							return navic.get_location()
						end,
						enabled = function()
							return navic.is_available()
						end,
					}
				}
			},
		},
	})
}
