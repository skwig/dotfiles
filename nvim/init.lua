local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("autocmd")
require("vim-options")
require("excommands")
require("remaps")
require("windows")
require("filetypes")
require("lazy").setup("plugins", {
  install = {
    missing = true,
    colorscheme = { "vscode" },
  },
})
