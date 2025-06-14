return {
  "mfussenegger/nvim-dap",
  ft = { "go" },
  enabled = true,
  -- event = "VeryLazy",
  dependencies = {
    "rcarriga/nvim-dap-ui",

    "nvim-neotest/nvim-nio",

    "williamboman/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",

    -- languages
    "leoluz/nvim-dap-go",
  },
  keys = function(_, keys)
    local dap = require("dap")
    local dapui = require("dapui")
    return {
      { "<F5>", dap.continue, desc = "Debug: Start/Continue" },
      { "<F7>", dap.step_into, desc = "Debug: Step Into" },
      { "<S-F8>", dap.step_out, desc = "Debug: Step Out" },
      { "<F8>", dap.step_over, desc = "Debug: Step Over" },
      { "<F9>", dapui.open, desc = "dapui open" },
      { "<leader>ee", dap.toggle_breakpoint, desc = "Debug: Toggle Breakpoint" },
      {
        "<leader>B",
        function()
          dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Debug: Set Breakpoint",
      },
      { "<F6>", dapui.toggle, desc = "Debug: See last session result." },
      unpack(keys),
    }
  end,
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    require("mason-nvim-dap").setup({
      automatic_installation = true,

      handlers = {},

      ensure_installed = {
        "delve",
      },
    })

    dapui.setup({})

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

    require("dap-go").setup({
      delve = {
        detached = vim.fn.has("win32") == 0,
      },
    })
  end,
}
