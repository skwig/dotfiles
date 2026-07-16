vim.pack.add({
  { src = "https://github.com/tpope/vim-fugitive" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/kdheepak/lazygit.nvim" },
  -- dependencies
  { src = "https://github.com/nvim-lua/plenary.nvim" },
})

require("gitsigns").setup({
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
  },
  on_attach = function(bufnr)
    local gitsigns = require("gitsigns")

    local vimkeymapset = function(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    vimkeymapset("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gitsigns.nav_hunk("next")
      end
    end, { desc = "Jump to next git [c]hange" })

    vimkeymapset("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gitsigns.nav_hunk("prev")
      end
    end, { desc = "Jump to previous git [c]hange" })

    -- vimkeymapset("v", "<leader>cs", function()
    --   gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    -- end, { desc = "stage git hunk" })
    -- vimkeymapset("v", "<leader>cr", function()
    --   gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    -- end, { desc = "reset git hunk" })
    -- vimkeymapest("n", "<leader>cs", gitsigns.stage_hunk, { desc = "git [s]tage hunk" })
    vimkeymapset("n", "<leader>cu", gitsigns.reset_hunk, { desc = "git [u]ndo" })
    -- vimkeymapset("n", "<leader>cS", gitsigns.stage_buffer, { desc = "git [S]tage buffer" })
    -- vimkeymapset("n", "<leader>cR", gitsigns.reset_buffer, { desc = "git [R]eset buffer" })
    -- vimkeymapset("n", "<leader>cd", gitsigns.preview_hunk, { desc = "git [p]review hunk" })
    vimkeymapset("n", "<leader>ca", gitsigns.blame, { desc = "git [a]nnotate" })
    vimkeymapset("n", "<leader>cd", gitsigns.diffthis, { desc = "git [d]iff against index" })
    -- vimkeymapset("n", "<leader>cD", function()
    --   gitsigns.diffthis("@")
    -- end, { desc = "git [D]iff against last commit" })
    -- Toggles
    -- vimkeymapset("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "[T]oggle git show [b]lame line" })
    -- vimkeymapset("n", "<leader>tD", gitsigns.toggle_deleted, { desc = "[T]oggle git show [D]eleted" })
  end,
})

vim.keymap.set("n", "<leader>cc", "<CMD>LazyGit<CR>", { desc = "LazyGit" })
