return {
  "stevearc/overseer.nvim",
  config = function()
    local overseer = require("overseer")

    overseer.setup({

      bundles = {
        autostart_on_load = false,
      },
    })

    vim.keymap.set("n", "<leader>w", ":OverseerToggle<CR>")

    vim.keymap.set("n", "<leader>ff", ":OverseerRun run<CR>", { desc = "[FF] Run" })
    vim.keymap.set("n", "<leader>bb", ":OverseerRun build<CR>", { desc = "[B]uild" })
    vim.keymap.set("n", "<leader>tt", ":OverseerRun test<CR>", { desc = "[T]est" })
  end,
}
