-- bootstrap lazy.nvim, LazyVim and your plugins
local treesitter_site = vim.fn.stdpath("data") .. "/site"
local function fix_treesitter_runtimepath()
  vim.opt.rtp:remove(treesitter_site)
  vim.opt.rtp:prepend(treesitter_site .. "/")
end

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  once = true,
  callback = fix_treesitter_runtimepath,
})
require("config.lazy")
fix_treesitter_runtimepath()
