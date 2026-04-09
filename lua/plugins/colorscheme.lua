return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      background = {
        light = "latte",
        dark = "mocha",
      },
      transparent_background = false,
      term_colors = false,
      no_italic = true,
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },

  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local now = os.date("*t")
      local hour = now.hour % 12
      if hour == 0 then
        hour = 12
      end

      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}
      opts.dashboard.preset.header = table.concat({
        os.date("%A"),
        string.format("%d:%02d %s", hour, now.min, now.hour >= 12 and "PM" or "AM"),
      }, "\n")
    end,
  },
}
