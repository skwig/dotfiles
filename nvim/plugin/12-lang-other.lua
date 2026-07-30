vim.lsp.enable({
  "bash-language-server",
  "qmlls",
})

local conform = require("conform")
conform.formatters_by_ft.json = { "fixjson" }
conform.formatters_by_ft.json5 = { "fixjson" }
conform.formatters_by_ft.jsonc = { "fixjson" }
conform.formatters_by_ft.css = { "prettierd" }
conform.formatters_by_ft.html = { "prettierd" }
conform.formatters_by_ft.javascript = { "prettierd" }
