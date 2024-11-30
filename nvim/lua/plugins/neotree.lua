return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		local neotree = require("neo-tree")
		neotree.setup({})

		vim.keymap.set("n", "<leader>hf", ":Neotree filesystem reveal left<CR>", { silent = true })
		vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", { silent = true })
	end,
}
