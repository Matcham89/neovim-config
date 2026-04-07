-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- High-visibility cursor highlights, re-applied after every colorscheme change
local cursor_group = vim.api.nvim_create_augroup("local_cursor_highlights", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  group = cursor_group,
  callback = function()
    vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#FFCC00" })
    vim.api.nvim_set_hl(0, "lCursor", { fg = "#000000", bg = "#FFCC00" })
    vim.api.nvim_set_hl(0, "CursorIM", { fg = "#000000", bg = "#FFCC00" })
  end,
})
-- Apply immediately for the current session
vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#FFCC00" })
vim.api.nvim_set_hl(0, "lCursor", { fg = "#000000", bg = "#FFCC00" })
vim.api.nvim_set_hl(0, "CursorIM", { fg = "#000000", bg = "#FFCC00" })

local autoread_group = vim.api.nvim_create_augroup("local_autoread", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = autoread_group,
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})
