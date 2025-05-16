return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Configure ruff
        ruff = {
          init_options = {
            settings = {
              lineLength = 120,
              organizeImports = true,
              fixAll = true,
              lint = {
                select = { "I", "E", "W", "F", "S" },
              },
            },
          },
        },
        -- Configure pylsp
        pylsp = {
          settings = {
            pylsp = {
              plugins = {
                -- Disable linting and formatting (handled by ruff)
                pycodestyle = { enabled = false },
                pyflakes = { enabled = false },
                pylint = { enabled = false },
                flake8 = { enabled = false },
                autopep8 = { enabled = false },
                yapf = { enabled = false },
                pylsp_black = { enabled = false },
                pylsp_isort = { enabled = false },
                mccabe = { enabled = false },
                -- Install pylsp_mypy using `:PylspInstall pylsp-mypy`
                pylsp_mypy = { enabled = true },
              },
            },
          },
        },
      },
    },
  },
}
