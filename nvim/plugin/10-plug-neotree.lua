vim.pack.add({
  { src = "https://github.com/nvim-neo-tree/neo-tree.nvim", version = vim.version.range("3") },
  -- dependencies
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
})

require("neo-tree").setup({
  filesystem = {
    hijack_netrw_behavior = "disabled",
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
