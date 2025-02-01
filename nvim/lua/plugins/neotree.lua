return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  event = "VeryLazy",
  config = function()
    local neotree = require("neo-tree")
    neotree.setup({
      filesystem = {
        filtered_items = {
          -- visible = true,
          hide_dotfiles = false,
          -- hide_gitignored = true,
        },
      },
    })
    vim.keymap.set(
      "n",
      "<leader>jf",
      ":Neotree filesystem reveal left<CR>",
      { desc = "[J]ump to [F]ilesystem", silent = true }
    )
  end,
}
