vim.lsp.enable({ "lua_ls" })

require("conform").formatters_by_ft.lua = { "stylua" }
