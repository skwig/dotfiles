return {
  "folke/flash.nvim",
  event = "VeryLazy",
  config = function()
    local flash = require("flash")

    flash.setup({
      modes = {
        char = {
          enabled = false,
        },
      },
      label = {
        before = true,
        after = false,
        rainbow = {},
      },
    })

    vim.keymap.set("n", "<leader>h", flash.jump, { desc = "[H]op" })

    vim.api.nvim_set_hl(0, "FlashLabel", { link = "Cursor" })
  end,
}
