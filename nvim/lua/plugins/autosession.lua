return {
  "rmagatti/auto-session",
  lazy = false,
  config = function()
    -- `terminal` intentionally omitted, as tasks started by overseer get persisted and automatically start on returning to the session
    vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions"

    local autosession = require("auto-session")
    autosession.setup({
      suppressed_dirs = { "~", "~/", "~/Downloads" },
    })

    vim.keymap.set("n", "<leader>si", "<CMD>AutoSession search<CR>", { desc = "[S]earch Sess[I]on" })
  end,
}
