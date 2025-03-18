-- local IS_DEV = false

local prompts = {
	Explain =
	"As a Senior software developer, please explain how the following code works, including its logic and purpose, as you will to a junior developer.",
	Review =
	"As a Senior software developer, please review the following code and provide suggestions for improvement, focusing on best practices and potential issues, as you will to a junior developer.",
	Tests =
	"As a Senior software developer, please explain how the selected code works, then generate unit tests for it to ensure its functionality, as you will to a junior developer.",
	Refactor =
	"As a Senior software developer, please refactor the following code to improve its clarity and readability, while maintaining its functionality, as you will to a junior developer.",
	ExplainError =
	"As a Senior software developer, please explain the error in the following code and what might be causing it, as you will to a junior developer.",
	FixError =
	"As a Senior software developer, please explain the error in the following text and provide a solution, detailing the logic behind the issue and the fix, as you will to a junior developer.",
	BetterNamings =
	"As a Senior software developer, please provide better names for the following variables and functions, ensuring they are descriptive and follow naming conventions, as you will to a junior developer.",
	Documentation =
	"As a Senior software developer, please provide proper documentation for the following code, which can be shared with other developers and used for development, as you will to a junior developer.",
	Summarize =
	"As a Senior software developer, please summarize the following text, highlighting the key points and important information, as you will to a junior developer.",
}

return {
	{ import = "custom.plugins.copilot" },
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "main",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
		},
		opts = {
			model = "gpt-4o",
			prompts = prompts,
			mappings = {
				complete = { insert = "<Tab>" },
				close = { normal = "q", insert = "<C-c>" },
				reset = { normal = "<C-x>", insert = "<C-x>" },
				submit_prompt = { normal = "<CR>", insert = "<C-CR>" },
				accept_diff = { normal = "<C-y>", insert = "<C-y>" },
				stop_response = { normal = "<C-t>", insert = "<C-t>" },
				show_help = { normal = "g?" },
			},
		},
		config = function(_, opts)
			local chat = require("CopilotChat")
			chat.setup(opts)
			-- Custom Commands

			vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
				chat.ask(args.args, {
					selection = require("CopilotChat.select").visual,
					context = { "buffers" }
				})
			end, { nargs = "*", range = true })

			vim.api.nvim_create_user_command("CopilotChatInline", function(args)
				chat.ask(args.args, {
					selection = require("CopilotChat.select").visual,
					window = {
						layout = "float",
						relative = "cursor",
						width = 1,
						height = 0.4,
						row = 1,
					},
				})
			end, { nargs = "*", range = true })

			vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
				chat.ask(args.args, { selection = require("CopilotChat.select").buffer })
			end, { nargs = "*", range = true })

			-- Set buffer options for chat
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "copilot-*",
				callback = function()
					vim.opt_local.relativenumber = false
					vim.opt_local.number = false
					if vim.bo.filetype == "copilot-chat" then
						vim.bo.filetype = "markdown"
					end
				end,
			})
		end,
		event = "VeryLazy",
		keys = {
			-- Prompt Selection
			{
				"<leader>ap",
				function() require("CopilotChat").select_prompt({ context = { "buffers" } }) end,
				desc = "CopilotChat - Prompt actions",
			},
			{
				"<leader>ap",
				function() require("CopilotChat").select_prompt() end,
				mode = "x",
				desc = "CopilotChat - Prompt actions",
			},
			-- Code Related Commands
			{ "<leader>ae", "<cmd>CopilotChatExplain<cr>",       desc = "CopilotChat - Explain code" },
			-- { "<leader>at", "<cmd>CopilotChatTests<cr>",         desc = "CopilotChat - Generate tests" },
			{ "<leader>ar", "<cmd>CopilotChatReview<cr>",        desc = "CopilotChat - Review code" },
			{ "<leader>aR", "<cmd>CopilotChatRefactor<cr>",      desc = "CopilotChat - Refactor code" },
			{ "<leader>an", "<cmd>CopilotChatBetterNamings<cr>", desc = "CopilotChat - Better Naming" },
			-- { "C-c",        "<cmd>CopilotChatStop<cr>",          desc = "CopilotChat - Stop Input" },


			-- Chat with Copilot in visual mode
			{ "<leader>av", ":CopilotChatVisual ",               mode = "x",                              desc = "CopilotChat - Open in vertical split" },
			{ "<leader>ax", ":CopilotChatInline",                mode = "x",                              desc = "CopilotChat - Inline chat" },
			-- Custom Input for CopilotChat
			{
				"<leader>ai",
				function()
					local input = vim.fn.input("Ask Copilot: ")
					if input ~= "" then vim.cmd("CopilotChat " .. input) end
				end,
				desc = "CopilotChat - Ask input",
			},
			-- Generate Commit Message Based on Git Diff
			{ "<leader>am", "<cmd>CopilotChatCommit<cr>", desc = "CopilotChat - Generate commit message for all changes" },
			-- Quick Chat with Copilot
			{
				"<leader>aq",
				function()
					local input = vim.fn.input("Quick Chat: ")
					if input ~= "" then vim.cmd("CopilotChatBuffer " .. input) end
				end,
				desc = "CopilotChat - Quick chat",
			},
			-- Fix Issues with Diagnostic
			-- { "<leader>af", "<cmd>CopilotChatFixError<cr>", desc = "CopilotChat - Fix Diagnostic" },
			-- Clear Buffer and Chat History
			{ "<leader>al", "<cmd>CopilotChatReset<cr>",  desc = "CopilotChat - Clear buffer and chat history" },
			-- Toggle Copilot Chat Vsplit
			{ "<leader>av", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle" },
			-- Copilot Chat Models
			-- { "<leader>a?", "<cmd>CopilotChatModels<cr>",   desc = "CopilotChat - Select Models" },
			-- Copilot Chat Agents
			-- { "<leader>aa", "<cmd>CopilotChatAgents<cr>",   desc = "CopilotChat - Select Agents" },
		},
	},
}
