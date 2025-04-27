-- NOPs
vim.keymap.set("n", "<leader>", "<NOP>", {})
vim.keymap.set("n", "<BS>", "<NOP>", {})
vim.keymap.set("n", "<CR>", "<NOP>", {})

vim.keymap.set({"n", "v", "o"}, "<S-u>", "<C-r>", {}) -- Redo with shift
vim.keymap.set({"n", "v", "o"}, "<S-k>", "10k", {}) -- Faster movement
vim.keymap.set({"n", "v", "o"}, "<S-j>", "10j", {}) -- Faster movement
