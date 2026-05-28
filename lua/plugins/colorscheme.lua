return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "default",
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
