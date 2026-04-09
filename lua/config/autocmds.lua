-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Per-mode cursor colours, re-applied after every colorscheme change
local function set_cursor_highlights()
  vim.api.nvim_set_hl(0, "NormalCursor", { fg = "#000000", bg = "#FF8C00" }) -- orange
  vim.api.nvim_set_hl(0, "InsertCursor", { fg = "#000000", bg = "#00CC66" }) -- green
  vim.api.nvim_set_hl(0, "VisualCursor", { fg = "#000000", bg = "#5599FF" }) -- blue
end

local cursor_group = vim.api.nvim_create_augroup("local_cursor_highlights", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  group = cursor_group,
  callback = set_cursor_highlights,
})
set_cursor_highlights()

-- Reset cursor to block when leaving Neovim so the terminal cursor stays correct
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    vim.opt.guicursor = "a:block"
    io.write("\27[2 q") -- ESC [ 2 q = solid block
  end,
})

local autoread_group = vim.api.nvim_create_augroup("local_autoread", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = autoread_group,
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})
