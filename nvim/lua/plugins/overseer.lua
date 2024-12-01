return {
	"stevearc/overseer.nvim",
	config = function()
		local overseer = require("overseer")

		overseer.setup({
			bundles = {
				autostart_on_load = false,
			},
		})
	end,
}
