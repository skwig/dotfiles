return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    vim.keymap.set(
      "n",
      "<leader>jf",
      ":Neotree filesystem reveal left<CR>",
      { desc = "[J]ump to [F]ilesystem", silent = true }
    )
  end,
}
