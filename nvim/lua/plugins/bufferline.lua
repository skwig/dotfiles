return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local bufferline = require("bufferline")

    -- Setting options.highlights.fill.bg doesnt seem to work, but this does
    vim.cmd([[ hi BufferLineFill guibg='#111111' ]])

    bufferline.setup({
      options = {
        mode = "buffers",
        style_preset = bufferline.style_preset.default,
        separator_style = "slant",
        offsets = {
          {
            filetype = "neo-tree",
            separator = true,
          },
        },
      },
    })
  end,
}
