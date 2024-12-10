vim.keymap.set("v", "<leader>xx", ":lua<CR>", {})
vim.keymap.set("n", "<leader>xx", ":.lua<CR>", {})
vim.keymap.set("n", "<leader>xs", ":%!", { desc = "E[X]ecute [S]hell" })
vim.keymap.set("n", "<leader>xft", ":set filetype=", { desc = "E[X]ecute set [F]ile [T]ype" })
