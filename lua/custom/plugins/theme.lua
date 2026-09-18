vim.pack.add {
  { src = 'https://github.com/rose-pine/neovim', name = 'rose-pine' },
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
}
require('catppuccin').setup {
  default_integrations = true,
  flavour = 'frappe',
  transparent_background = false,
  highlight_overrides = {
    frappe = function(frappe)
      return {
        ['@comment'] = { fg = frappe.surface2, style = { 'italic' } },
        Normal = { bg = 'NONE' },
        NormalNC = { bg = 'NONE' },
        TelescopeNormal = { bg = frappe.mantle },
        Pmenu = { bg = frappe.mantle },
      }
    end,
  },
}
vim.cmd.colorscheme 'rose-pine-moon'
