vim.pack.add({
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/rcarriga/nvim-dap-ui" },
  -- dependencies
  { src = "https://github.com/nvim-neotest/nvim-nio" },
})

local dap = require("dap")
local dapui = require("dapui")

dapui.setup()

-- Change breakpoint icons
vim.api.nvim_set_hl(0, "DapBreak", { fg = "#e51400" })
vim.api.nvim_set_hl(0, "DapStop", { fg = "#ffcc00" })
local breakpoint_icons = vim.g.have_nerd_font
    and {
      Breakpoint = "",
      BreakpointCondition = "",
      BreakpointRejected = "",
      LogPoint = "",
      Stopped = "",
    }
  or {
    Breakpoint = "●",
    BreakpointCondition = "⊜",
    BreakpointRejected = "⊘",
    LogPoint = "◆",
    Stopped = "⭔",
  }

for type, icon in pairs(breakpoint_icons) do
  local tp = "Dap" .. type
  local hl = (type == "Stopped") and "DapStop" or "DapBreak"
  vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
end

dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.launch["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
vim.keymap.set("n", "<F7>", dap.step_into, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<S-F8>", dap.step_out, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<F8>", dap.step_over, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F9>", dapui.open, { desc = "dapui open" })
vim.keymap.set("n", "<leader>ee", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<F6>", dapui.toggle, { desc = "Debug: See last session result." })
