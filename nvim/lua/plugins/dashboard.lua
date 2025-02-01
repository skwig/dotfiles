return {
  "goolord/alpha-nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  event = "VimEnter",
  config = function()
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
      dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
      dashboard.button(".", "  Recently used files", ":Telescope oldfiles<CR>"),
      dashboard.button("f", "󰱼  Find file", ":Telescope find_files<CR>"),
      dashboard.button("g", "󰊄  Find text", ":Telescope live_grep <CR>"),
      dashboard.button("u", "󰚰  Update", ":Lazy update <CR>"),
      dashboard.button("q", "󰩈  Quit NVIM", ":qa<CR>"),
    }

    dashboard.section.mru_cwd.val = {}
    dashboard.section.bottom_buttons.val = {}

    vim.api.nvim_create_autocmd("User", {
      callback = function()
        local stats = require("lazy").stats()
        local ms = math.floor(stats.startuptime * 100) / 100
        dashboard.section.footer.val = {
          {
            type = "text",
            val = { "󱐌 Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" },
            opts = {
              hl = "Comment",
            },
          },
        }
        -- dashboard.section.footer.type = "text"
        -- dashboard.section.footer.val =
        --
        -- dashboard.section.footer.val =
        --   { " ", " ", " ", " Loaded " .. stats.count .. " plugins  in " .. ms .. " ms " }
        -- dashboard.section.header.opts.hl = "DashboardFooter"
        -- dashboard.section.footer.opts.hl = "Comment"
        -- dashboard.section.footer = {
        --   type = "text",
        --   val = { "󱐌 Lazy-loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" },
        --   -- opts = {
        --   --   hl = "Comment",
        --   --   -- shrink_margin = false,
        --   --   -- wrap = "overflow";
        --   -- },
        -- }

        pcall(vim.cmd.AlphaRedraw)
      end,
    })
    dashboard.opts.opts.noautocmd = true
    alpha.setup(dashboard.opts)
  end,
}
