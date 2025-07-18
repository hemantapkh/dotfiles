return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim" },
      { "mason-org/mason-lspconfig.nvim" },
    },
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "basic",
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
                  reportAny = "none",
                  reportGeneralTypeIssues = "warning",
                },
              },
            },
          },
        },
        ruff = {
          init_options = {
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
  },

  -- Mason for installing pyright and ruff
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "basedpyright", "ruff" },
    },
  },
}
