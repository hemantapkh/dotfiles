return {
  "lewis6991/gitsigns.nvim",
  opts = {
    current_line_blame = true, -- Enable inline blame
    current_line_blame_opts = {
      virt_text = true, -- Display blame as virtual text
      virt_text_pos = "eol", -- Position at end of line (like VS Code)
      delay = 100, -- Delay in ms for blame to appear
      ignore_whitespace = false, -- Include whitespace changes
      virt_text_priority = 100, -- Priority for virtual text
    },
    current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>", -- Customize blame format
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end
      -- Default LazyVim keymaps (you can customize)
      map("n", "<leader>ghb", function()
        gs.blame_line({ full = true })
      end, "Blame Line")
      map("n", "<leader>ghB", gs.blame, "Blame Buffer")
      map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
    end,
  },
}
