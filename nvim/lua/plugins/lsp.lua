return {
  {
    "folke/lazydev.nvim",
    event = "VeryLazy",
    ft = "lua",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "neovim/nvim-lspconfig", -- For OK defaults of LSP configs
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      { "WhoIsSethDaniel/mason-tool-installer.nvim" },
      { "j-hui/fidget.nvim", opts = {} }, -- For LSP loading notifications
      { "williamboman/mason-lspconfig.nvim" }, -- For lspconfig names for mason-tool-installer
    },
    config = function()
      local telescope_builtin = require("telescope.builtin")
      local mason = require("mason")
      local mason_tool_installer = require("mason-tool-installer")

      local install_lsps = {
        "fixjson",
        "gopls",
        "hyprls",
        "lua_ls",
        "omnisharp",
        "prettierd",
        "stylua",
        "tofu-ls",
        "typescript-language-server",
        "yamlls",
        "bashls",
      }

      local preinstalled_lsps = {
        "nixd",
      }

      local lsps = vim.tbl_deep_extend("force", install_lsps, preinstalled_lsps)

      mason.setup()
      mason_tool_installer.setup({ ensure_installed = install_lsps })

      -- tofu-ls doesnt want to work on its own for some reason
      vim.lsp.config("tofu-ls", {
        cmd = { "tofu-ls", "serve" },
        filetypes = { "opentofu", "opentofu-vars", "terraform" },
        root_markers = { ".terraform", ".git" },
      })

      vim.lsp.enable(lsps)

      vim.diagnostic.config({
        -- virtual_lines = true,
        virtual_lines = {
          current_line = true,
        },
      })

      if vim.g.have_nerd_font then
        local signs = { Error = "", Warn = "", Hint = "", Info = "" }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("<leader>d", vim.lsp.buf.definition, "(jump to) [D]efinition")
          map("<leader>u", telescope_builtin.lsp_references, "(jump to) [U]sages")
          map("<leader>k", vim.lsp.buf.code_action, "Show A[k]tions")
          map("<leader>v", vim.lsp.buf.hover, "Ho[V]er")

          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

          map("<leader>ji", telescope_builtin.lsp_implementations, "[J]ump to [I]mplementation")
          map("<leader>jm", telescope_builtin.lsp_document_symbols, "[J]ump to [M]embers")
          -- map("<C-k>", vim.lsp.buf.signature_help, "[J]ump to Pa[R]ameters", { "i", "n" })
          --
          -- Highlight references of the word under the cursor on hold
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
              end,
            })
          end
        end,
      })
    end,
  },
}
