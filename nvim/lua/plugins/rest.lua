return {
  "rest-nvim/rest.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "http")
    end,
  },
  config = function()
    require("rest-nvim").setup({})

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "http",
      callback = function()
        vim.keymap.set("n", "<leader>k", "<cmd>Rest run<CR>", {
          buffer = true,
          desc = "Run REST request",
        })
      end,
    })
  end,
}
