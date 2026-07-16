vim.pack.add({
  { src = "https://github.com/Mofiqul/vscode.nvim" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/akinsho/bufferline.nvim" },
  { src = "https://github.com/Bekaboo/dropbar.nvim" },
  { src = "https://github.com/goolord/alpha-nvim" },
  -- dependencies
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
})

require("vscode").setup({
  style = "dark",
})

vim.cmd.colorscheme("vscode")
vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, fg = "#db4b4b" })

require("lualine").setup({
  options = { theme = "vscode" },
  sections = {
    lualine_x = { "encoding", "fileformat", "filetype" },
  },
})

require("bufferline").setup({
  options = {
    mode = "buffers",
    separator_style = "slant",
    offsets = {
      {
        filetype = "neo-tree",
        separator = true,
      },
    },
  },
})

-- Setting options.highlights.fill.bg doesnt seem to work, but this does
vim.cmd([[ hi BufferLineFill guibg='#111111' ]])

vim.keymap.set("n", "<leader>;", require("dropbar.api").pick, { desc = "Pick symbols in dropbar" })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local alpha = require("alpha")
local dashboard = require("alpha.themes.startify")

dashboard.file_icons.provider = "devicons"
dashboard.section.header.val = {
  [[                                                         ]],
  [[  ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗ ]],
  [[  ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║ ]],
  [[  ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║ ]],
  [[  ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║ ]],
  [[  ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║ ]],
  [[  ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝ ]],
}

dashboard.section.top_buttons.val = {
  dashboard.button("e", "  New file", "<cmd>ene <BAR> startinsert <CR>"),
  dashboard.button("i", "  Saved sessions", "<cmd>AutoSession search<CR>"),
  dashboard.button(".", "  Recently used files", "<cmd>Telescope oldfiles<CR>"),
  dashboard.button("f", "󰱼  Find file", "<cmd>Telescope find_files<CR>"),
  dashboard.button("g", "󰊄  Find text", "<cmd>Telescope live_grep <CR>"),
  -- dashboard.button("u", "󰚰  Update", "<cmd>Lazy update <CR>"),
  dashboard.button("q", "󰩈  Quit NVIM", "<cmd>qa<CR>"),
}

dashboard.section.mru_cwd.val = {}
dashboard.section.bottom_buttons.val = {}

vim.api.nvim_create_autocmd("User", {
  callback = function()
    local ms = math.floor((vim.uv.hrtime() - vim.g.start_time) / 1e6 * 100) / 100

    dashboard.section.footer.val = {
      {
        type = "text",
        val = { string.format("󱐌 Loaded plugins in %.2fms", ms) },
        opts = {
          hl = "Comment",
        },
      },
    }

    pcall(vim.cmd.AlphaRedraw)
  end,
})
dashboard.opts.opts.noautocmd = true

alpha.setup(dashboard.opts)
