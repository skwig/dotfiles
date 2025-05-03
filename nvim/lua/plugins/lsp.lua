return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      { "williamboman/mason-lspconfig.nvim" },
      { "WhoIsSethDaniel/mason-tool-installer.nvim" },
      { "j-hui/fidget.nvim", opts = {} },
      { "hrsh7th/cmp-nvim-lsp" },
      { "someone-stole-my-name/yaml-companion.nvim" },
    },
    config = function()
      local lspconfig = require("lspconfig")
      local telescope_builtin = require("telescope.builtin")
      local mason = require("mason")
      local mason_tool_installer = require("mason-tool-installer")
      local mason_lspconfig = require("mason-lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local yaml_companion = require("yaml-companion")

      local lsps = { "gopls", "lua_ls", "stylua", "omnisharp", "yamlls", "terraformls", "nil", "hyprls", "prettierd", "fixjson", "nixfmt" }
      local capabilities =
        vim.tbl_deep_extend("force", lspconfig.util.default_config.capabilities, cmp_nvim_lsp.default_capabilities())

      lspconfig.util.default_config.capabilities = capabilities

      mason.setup()
      mason_tool_installer.setup({ ensure_installed = lsps })
      mason_lspconfig.setup({
        handlers = {
          function(server_name)
            lspconfig[server_name].setup({})
          end,

          lua_ls = function()
            lspconfig.lua_ls.setup({
              settings = {
                Lua = {
                  completion = {
                    callSnippet = "Replace",
                  },
                },
              },
            })
          end,

          gopls = function()
            lspconfig.gopls.setup({
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
            })
          end,

          omnisharp = function()
            lspconfig.omnisharp.setup({})
          end,

          yamlls = function()
            local cfg = yaml_companion.setup({
              builtin_matchers = {
                kubernetes = { enabled = false },
                cloud_init = { enabled = false },
              },
              schemas = {
                {
                  name = "Flux",
                  uri = "https://raw.githubusercontent.com/fluxcd-community/flux2-schemas/refs/heads/main/all.json",
                },
                {
                  name = "kubernetes",
                  uri = "kubernetes",
                },
              },
              lspconfig = {
                settings = {
                  yaml = {
                    validate = true,
                    hover = true,
                    completion = true,
                    trace = { server = "info" },
                  },
                },
              },
            })
            lspconfig.yamlls.setup(cfg)
          end,

          terraformls = function()
            lspconfig.terraformls.setup({})
          end,
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
          map("<leader>n", vim.lsp.buf.rename, "Re[n]ame")
          map("<leader>k", vim.lsp.buf.code_action, "Show A[k]tions")
          map("<leader>v", vim.lsp.buf.hover, "Ho[V]er")

          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

          map("<leader>ji", telescope_builtin.lsp_implementations, "[J]ump to [I]mplementation")
          map("<leader>jm", telescope_builtin.lsp_document_symbols, "[J]ump to [M]embers")
          map("<leader>jr", vim.lsp.buf.signature_help, "[J]ump to Pa[R]ameters")

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map("<leader>th", vim.lsp.inlay_hint.enable, "[T]oggle Inlay [H]ints")
          end

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
    "Bilal2453/luvit-meta",
    lazy = true,
    event = "VeryLazy",
  },
}
