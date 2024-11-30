return {
	"rmagatti/auto-session",
	config = function()
		local autosession = require("auto-session")
		autosession.setup({
			suppressed_dirs = { "~/", "~/Downloads" },
		})

		local sessionLens = require("auto-session.session-lens")
		vim.keymap.set("n", "<leader>so", sessionLens.search_session, { desc = "[S]earch Sessi[O]n" })
	end,
}
