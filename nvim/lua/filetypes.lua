vim.filetype.add({
  pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "hyprlang",
  callback = function()
    vim.bo.commentstring = "# %s"
  end,
})
