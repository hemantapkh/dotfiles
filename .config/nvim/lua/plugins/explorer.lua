-- The explorer shows dotfiles and gitignored files (dimmed); H and I toggle them.
-- File search and grep still skip them.
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          hidden = true,
          ignored = true,
          exclude = { "/.git", "/.DS_Store", "/__pycache__", "/.ruff_cache", "/.pytest_cache", "/.mypy_cache" },
        },
      },
    },
  },
}
