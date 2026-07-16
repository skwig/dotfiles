vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1") },
  -- dependencies
  { src = "https://github.com/saghen/blink.lib" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
})

require("blink.cmp").setup({
  keymap = {
    preset = "enter",

    ["<C-j>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
  },

  signature = {
    enabled = true,
  },

  appearance = {
    nerd_font_variant = "mono",

    kind_icons = {
      Text = "  ",
      Method = "  ",
      Function = "  ",
      Constructor = "  ",
      Field = "  ",
      Variable = "  ",
      Class = "  ",
      Interface = "  ",
      Module = "  ",
      Property = "  ",
      Unit = "  ",
      Value = "  ",
      Enum = "  ",
      Keyword = "  ",
      Snippet = "  ",
      Color = "  ",
      File = "  ",
      Reference = "  ",
      Folder = "  ",
      EnumMember = "  ",
      Constant = "  ",
      Struct = "  ",
      Event = "  ",
      Operator = "  ",
      TypeParameter = "  ",
    },
  },

  completion = {
    documentation = { auto_show = true },
    menu = {
      draw = {
        columns = {
          { "kind_icon" },
          { "label", "hint", gap = 1 },
        },
        components = {
          hint = {
            text = function(ctx)
              return ctx.item.detail
            end,
            highlight = "BlinkCmpLabelDescription",
          },
        },
      },
    },
  },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },

  fuzzy = { implementation = "prefer_rust_with_warning" },

  cmdline = {
    keymap = { preset = "inherit" },
    completion = { menu = { auto_show = false } },
  },
})
