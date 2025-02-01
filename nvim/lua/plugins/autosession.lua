return {
  "rmagatti/auto-session",
  event = "VeryLazy",
  config = function()
    local function get_cwd_as_name()
      local dir = vim.fn.getcwd(0)
      return dir:gsub("[^A-Za-z0-9]", "_")
    end

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
