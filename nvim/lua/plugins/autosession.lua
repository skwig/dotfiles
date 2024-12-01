return {
	"rmagatti/auto-session",
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
			pre_save_cmds = {
				function()
					local overseer = require("overseer")
					overseer.save_task_bundle(
						get_cwd_as_name(),
						nil,
						{ on_conflict = "overwrite" } -- Overwrite existing bundle, if any
					)
				end,
			},
			post_restore_cmds = {
				function()
					local overseer = require("overseer")
					overseer.load_task_bundle(get_cwd_as_name(), { ignore_missing = true, autostart = false })
				end,
			},
		})

		local sessionLens = require("auto-session.session-lens")
		vim.keymap.set("n", "<leader>so", sessionLens.search_session, { desc = "[S]earch Sessi[O]n" })
	end,
}
