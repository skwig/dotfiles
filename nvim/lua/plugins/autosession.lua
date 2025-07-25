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

    local sessionLens = require("auto-session.session-lens")
    vim.keymap.set("n", "<leader>si", sessionLens.search_session, { desc = "[S]earch Sess[I]on" })
  end,
}
