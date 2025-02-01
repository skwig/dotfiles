return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  event = "VeryLazy",
  config = function()
    local refactoring = require("refactoring")
    refactoring.setup({
      prompt_func_return_type = {
        go = true,
        cpp = true,
        c = true,
        java = true,
      },
      -- prompt for function parameters
      prompt_func_param_type = {
        go = true,
        cpp = true,
        c = true,
        java = true,
      },
    })

    local telescope = require("telescope")
    telescope.load_extension("refactoring")

    vim.keymap.set({ "n", "x" }, "<leader>rr", function()
      telescope.extensions.refactoring.refactors()
    end)

    vim.keymap.set("x", "<leader>rm", ":Refactor extract<CR>", { desc = "[R]efactor [M]ethod" })
    vim.keymap.set("x", "<leader>rfm", ":Refactor extract_to_file<CR>", { desc = "[R]efactor [F]ile [M]ethod" })

    vim.keymap.set("x", "<leader>rv", ":Refactor extract_var<CR>", { desc = "[R]efactor [M]ethod [F]ile" })

    vim.keymap.set({ "n", "x" }, "<leader>ri", ":Refactor inline_var<CR>", { desc = "[R]efactor [i]nline variable" })
    vim.keymap.set("n", "<leader>rI", ":Refactor inline_func<CR>", { desc = "[R]efactor [I]nline function" })

    vim.keymap.set("n", "<leader>rb", ":Refactor extract_block<CR>", { desc = "[R]efactor [B]lock" })
    vim.keymap.set("n", "<leader>rfb", ":Refactor extract_block_to_file<CR>", { desc = "[R]efactor [F]ile [B]lock " })
    -- Extract block supports only normal mode
  end,
}
