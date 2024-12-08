return {
  "folke/flash.nvim",
  config = function()
    local flash = require("flash")

    flash.setup({
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
