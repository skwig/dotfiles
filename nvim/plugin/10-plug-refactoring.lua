vim.pack.add({
  { src = "https://github.com/ThePrimeagen/refactoring.nvim" },
  -- dependencies
  { src = "https://github.com/lewis6991/async.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

vim.keymap.set({ "n", "x" }, "<leader>rr", function()
  require("refactoring").select_refactor()
end, { desc = "[R]efactor" })

vim.keymap.set("x", "<leader>rm", ":Refactor extract<CR>", { desc = "[R]efactor [M]ethod" })
vim.keymap.set("x", "<leader>rfm", ":Refactor extract_to_file<CR>", { desc = "[R]efactor [F]ile [M]ethod" })

vim.keymap.set("x", "<leader>rv", ":Refactor extract_var<CR>", { desc = "[R]efactor [M]ethod [F]ile" })

vim.keymap.set({ "n", "x" }, "<leader>ri", ":Refactor inline_var<CR>", { desc = "[R]efactor [i]nline variable" })
vim.keymap.set("n", "<leader>rI", ":Refactor inline_func<CR>", { desc = "[R]efactor [I]nline function" })

-- Extract block supports only normal mode
vim.keymap.set("n", "<leader>rb", ":Refactor extract_block<CR>", { desc = "[R]efactor [B]lock" })
vim.keymap.set("n", "<leader>rfb", ":Refactor extract_block_to_file<CR>", { desc = "[R]efactor [F]ile [B]lock " })
