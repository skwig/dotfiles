return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local yaml_companion = require("yaml-companion")

    local function get_schema()
      local schema = yaml_companion.get_buf_schema(0)
      if schema.result[1].name == "none" then
        return ""
      end
      return schema.result[1].name
    end

    lualine.setup({
      options = {
        theme = "vscode",
      },
      sections = {
        lualine_x = { "encoding", "fileformat", "filetype", get_schema },
      },
    })
  end,
}
