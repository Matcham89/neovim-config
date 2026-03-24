-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_php_lsp = "intelephense"
vim.g.root_spec = {
  "lsp",
  {
    ".git",
    ".terraform",
    "Chart.yaml",
    "go.work",
    "go.mod",
    "pyproject.toml",
    "requirements.txt",
    "Pipfile",
    "composer.json",
    "ansible.cfg",
    ".ansible-lint",
    "Dockerfile",
    "Containerfile",
    "docker-compose.yml",
    "docker-compose.yaml",
    "compose.yml",
    "compose.yaml",
    "Taskfile.yml",
    "Taskfile.yaml",
    "Makefile",
    "*.toml",
    "lua",
  },
  "cwd",
}
vim.opt.autoread = true

