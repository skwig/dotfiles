vim.pack.add({
  { src = "https://github.com/stevearc/conform.nvim" },
})

local conform = require("conform")

conform.setup({
  notify_on_error = false,
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
  formatters_by_ft = {},
})

vim.keymap.set("n", "gq", function()
  conform.format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })
