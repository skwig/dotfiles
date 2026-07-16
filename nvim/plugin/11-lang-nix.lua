vim.lsp.enable({ "nixd" })

require("conform").formatters_by_ft.nix = { "nixfmt" }
