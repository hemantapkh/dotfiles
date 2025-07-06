return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
    },
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                diagnosticMode = "workspace",
                autoImportCompletions = true,
                useTypingExtensions = true,
                inlayHints = {
                  functionReturnTypes = true,
                  genericTypes = true,
                  callArgumentNames = true,
                  variableTypes = true,
                },
                diagnosticSeverityOverrides = {
                  -- Disabling reports handled by ruff
                  reportUnusedImport = "none",
                  reportUnusedVariable = "none",
                  reportUndefinedVariable = "none",
                  reportMissingTypeStubs = "none",
                  reportAny = "warning",
                  reportGeneralTypeIssues = "warning",
                },
              },
            },
          },
        },
        ruff = {
          settings = {
            lineLength = 120,
            lint = {
              select = { "I", "E", "W", "F", "S" },
            },
          },
        },
      },
    },
  },

  -- Mason for installing pyright and ruff
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = { "basedpyright", "ruff" },
    },
  },
}
