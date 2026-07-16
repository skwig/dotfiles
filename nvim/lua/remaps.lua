-- NOPs
vim.keymap.set("n", "<leader>", "<NOP>", {})
vim.keymap.set("n", "<BS>", "<NOP>", {})
vim.keymap.set("n", "<CR>", "<NOP>", {})

vim.keymap.set({ "n", "v", "o" }, "<S-u>", "<C-r>", {}) -- Redo with shift

vim.keymap.set({ "n", "v", "o" }, "gj", "J", {})

-- Faster movement
vim.keymap.set({ "n", "v", "o" }, "<S-k>", "10k", {})
vim.keymap.set({ "n", "v", "o" }, "<S-j>", "10j", {})

-- Clipboard
vim.keymap.set({ "n", "v", "o" }, "<leader>y", '"+y', {})
vim.keymap.set({ "n", "v", "o" }, "<leader>Y", '"+Y', {})
vim.keymap.set({ "n", "v", "o" }, "<leader>p", '"+p', {})
vim.keymap.set({ "n", "v", "o" }, "<leader>P", '"+P', {})

-- Excommands
vim.keymap.set("v", "<leader>xx", ":lua<CR>", {})
vim.keymap.set("n", "<leader>xx", ":.lua<CR>", {})
vim.keymap.set("n", "<leader>xs", ":%!", { desc = "E[X]ecute [S]hell" })
vim.keymap.set("n", "<leader>xft", ":set filetype=", { desc = "E[X]ecute set [F]ile [T]ype" })

-- Windows
vim.keymap.set("n", "<A-h>", "<C-w>h")
vim.keymap.set("n", "<A-j>", "<C-w>j")
vim.keymap.set("n", "<A-k>", "<C-w>k")
vim.keymap.set("n", "<A-l>", "<C-w>l")
vim.keymap.set("n", "<A-i>", ":bprev<CR>")
vim.keymap.set("n", "<A-o>", ":bnext<CR>")
