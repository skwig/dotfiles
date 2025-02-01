return {
  {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    init = function()
      local vscode = require("vscode")

      vscode.setup({
        style = "dark",
      })

      vim.cmd.colorscheme("vscode")
      vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, fg = "#db4b4b" })
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },
}
