return {
  {
    -- Not the recommended way to install this, but necessary while its
    -- luarocks dependencies are messed up.
    -- See https://github.com/rest-nvim/rest.nvim/issues/559
    "rest-nvim/rest.nvim",
    build = false,
    ft = "http",
    dependencies = {
      "nvim-neotest/nvim-nio",
      {
        -- Lazy.nvim does not recognize this library's rocksfile, so add it
        -- to package path manually.
        "manoelcampos/xml2lua",
        config = function(plugin)
          package.path = package.path .. ";" .. plugin.dir .. "/?.lua"
        end,
      },
      "lunarmodules/lua-mimetypes",
      "nvim-treesitter/nvim-treesitter",
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
  },
}
