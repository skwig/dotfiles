vim.pack.add({
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/junegunn/fzf" },
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
  -- dependencies
  { src = "https://github.com/nvim-lua/plenary.nvim" },
})

local telescope = require("telescope")
local builtin = require("telescope.builtin")
local themes = require("telescope.themes")

telescope.setup({
  defaults = {
    path_display = { "filename_first" },
  },
  pickers = {
    find_files = {
      file_ignore_patterns = { ".git" },
      hidden = true,
    },
    live_grep = {
      file_ignore_patterns = { ".git" },
      additional_args = function(_)
        return { "--hidden" }
      end,
    },
  },
  extensions = {
    ["ui-select"] = {
      themes.get_dropdown(),
    },
  },
})

-- Enable Telescope extensions if they are installed
pcall(telescope.load_extension, "fzf")
pcall(telescope.load_extension, "ui-select")

-- See `:help telescope.builtin`
vim.keymap.set("n", "<leader>ss", builtin.lsp_workspace_symbols, { desc = "[S]earch [S]ymbol" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "[S]earch Recent Files ('.' for repeat)" })
vim.keymap.set("n", "<leader>so", builtin.buffers, { desc = "[S]earch [O]pen files" })

vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>st", builtin.builtin, { desc = "[S]earch [T]elescope" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })

vim.keymap.set("n", "<leader>s/", function()
  builtin.live_grep({
    grep_open_files = true,
    prompt_title = "Live Grep in Open Files",
  })
end, { desc = "[S]earch [/] in Open Files" })

vim.keymap.set("n", "<leader>/", function()
  builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
    winblend = 10,
    previewer = false,
  }))
end, { desc = "[/] Fuzzily search in current buffer" })
