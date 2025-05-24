-- NOPs
vim.keymap.set("n", "<leader>", "<NOP>", {})
vim.keymap.set("n", "<BS>", "<NOP>", {})
vim.keymap.set("n", "<CR>", "<NOP>", {})

vim.keymap.set({"n", "v", "o"}, "<S-u>", "<C-r>", {}) -- Redo with shift

vim.keymap.set({"n", "v", "o"}, "gj", "J", {})

-- Faster movement
vim.keymap.set({"n", "v", "o"}, "<S-k>", "10k", {})
vim.keymap.set({"n", "v", "o"}, "<S-j>", "10j", {})

-- Clipboard
vim.keymap.set({"n", "v", "o"}, "<leader>y", '"+y', {})
vim.keymap.set({"n", "v", "o"}, "<leader>Y", '"+Y', {})
vim.keymap.set({"n", "v", "o"}, "<leader>p", '"+p', {})
vim.keymap.set({"n", "v", "o"}, "<leader>P", '"+P', {})
