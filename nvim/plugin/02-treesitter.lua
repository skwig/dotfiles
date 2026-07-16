vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
})

vim.keymap.set("x", "v", "an", { remap = true, desc = "Expand treesitter selection" })
vim.keymap.set("x", "V", "in", { remap = true, desc = "Shrink treesitter selection" })

require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
  },
})

local select = require("nvim-treesitter-textobjects.select")
local swap = require("nvim-treesitter-textobjects.swap")

vim.keymap.set({ "x", "o" }, "aa", function()
  select.select_textobject("@parameter.outer", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "ia", function()
  select.select_textobject("@parameter.inner", "textobjects")
end)

vim.keymap.set("n", "gl", function()
  swap.swap_next("@parameter.inner")
end)

vim.keymap.set("n", "gh", function()
  swap.swap_previous("@parameter.inner")
end)

local pre_installed_parsers = {
  "c",
  "lua",
  "markdown",
  "markdown_inline",
  "query",
  "vim",
  "vimdoc",
}

-- From https://github.com/nvim-treesitter/nvim-treesitter/issues/8221#issuecomment-3436658280
vim.api.nvim_create_autocmd("FileType", {
  group = config_augroup,
  callback = function(args)
    local treesitter = require("nvim-treesitter")
    local lang = vim.treesitter.language.get_lang(args.match)
    if vim.list_contains(treesitter.get_available(), lang) then
      if
        not vim.list_contains(treesitter.get_installed(), lang)
        and not vim.list_contains(pre_installed_parsers, lang)
      then
        treesitter.install(lang):wait()
      end
      vim.treesitter.start(args.buf)
    end
  end,
  desc = "Enable nvim-treesitter and install parser if not installed",
})
