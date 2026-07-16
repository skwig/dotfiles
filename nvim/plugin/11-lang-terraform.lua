vim.lsp.enable({ "tofu-ls" })

-- tofu-ls doesnt want to work on its own for some reason
vim.lsp.config("tofu-ls", {
  cmd = { "tofu-ls", "serve" },
  filetypes = { "terraform" },
  root_markers = { ".terraform", ".git" },
})
