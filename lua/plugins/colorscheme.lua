return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "day",
      day_brightness = 0.45,
      on_highlights = function(hl, c)
        hl.Keyword = { fg = c.orange, bold = true }
        hl.String = { fg = c.green1 }
        hl.Type = { fg = c.blue, bold = true }
        hl["@keyword"] = { fg = c.orange, bold = true }
        hl["@string"] = { fg = c.green1 }
        hl["@type"] = { fg = c.blue, bold = true }
        hl["@type.builtin"] = { fg = c.magenta }
        hl["@property"] = { fg = c.blue5, bold = true }
        hl["@variable.member"] = { fg = c.blue5 }
        hl["@punctuation.special"] = { fg = c.magenta }
      end,
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-day",
    },
  },
}
