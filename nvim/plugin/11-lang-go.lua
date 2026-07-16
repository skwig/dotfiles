vim.pack.add({
  { src = "https://github.com/leoluz/nvim-dap-go" },
})

vim.lsp.enable({ "gopls" })

require("conform").formatters_by_ft.go = { "gofmt" }

require("dap-go").setup({
  delve = {
    detached = vim.fn.has("win32") == 0,
  },
})
