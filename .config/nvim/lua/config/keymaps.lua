-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--vim.keymap.set("n", "<leader>gp", ":Gitsigns toogle_current_line_blame<CR>", { desc = "Blame for line" })
--vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })

-- Disable arrow keys in Normal, Visual, and Insert modes
vim.keymap.set({ "n", "v" }, "<Up>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<Down>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<Left>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<Right>", "<Nop>", { noremap = true, silent = true })
