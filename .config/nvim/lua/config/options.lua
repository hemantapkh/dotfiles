-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_python_lsp = "ruff"
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"

-- Auto fix Python imports and apply ruff fixes on save
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    if vim.bo.filetype == "python" then
      local context_organize = {
        only = { "source.organizeImports.ruff" },
      }
      vim.lsp.buf.code_action({
        context = context_organize,
        apply = true,
      })

      local context_fix = {
        only = { "source.fixAll.ruff" },
      }
      vim.lsp.buf.code_action({
        context = context_fix,
        apply = true,
      })
    end
  end,
})
