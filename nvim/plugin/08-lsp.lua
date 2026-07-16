vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
  -- dependencies
  { src = "https://github.com/j-hui/fidget.nvim" },
})

require("fidget").setup({})

local telescope_builtin = require("telescope.builtin")

vim.diagnostic.config({
  virtual_lines = {
    current_line = true,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    local vimkeymapset = function(keys, func, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    vimkeymapset("<leader>d", vim.lsp.buf.definition, "(jump to) [D]efinition")
    vimkeymapset("<leader>u", telescope_builtin.lsp_references, "(jump to) [U]sages")
    vimkeymapset("<leader>k", vim.lsp.buf.code_action, "Show A[k]tions")
    vimkeymapset("<leader>v", vim.lsp.buf.hover, "Ho[V]er")

    vimkeymapset("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

    vimkeymapset("<leader>ji", telescope_builtin.lsp_implementations, "[J]ump to [I]mplementation")
    vimkeymapset("<leader>jm", telescope_builtin.lsp_document_symbols, "[J]ump to [M]embers")
    -- vimkeymapset("<C-k>", vim.lsp.buf.signature_help, "[J]ump to Pa[R]ameters", { "i", "n" })

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
