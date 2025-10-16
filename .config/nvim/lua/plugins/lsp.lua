return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim" },
      { "mason-org/mason-lspconfig.nvim" },
    },
    opts = {
      servers = {
        ruff = {
          init_options = {
            settings = {
              lineLength = 120,
              lint = {
                select = { "I", "E", "W", "F", "S" },
                ignore = {},
              },
            },
          },
        },
        ty = {
          settings = {
            ty = {
              -- ty language server settings can be added here if needed
            },
          },
        },
      },
    },
  },
}
