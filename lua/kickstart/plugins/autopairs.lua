-- autopairs
-- https://github.com/windwp/nvim-autopairs

vim.pack.add { 'https://github.com/windwp/nvim-autopairs' }
require('nvim-autopairs').setup {
  disable_filetype = { 'TelescopePrompt', 'zig', 'odin', 'vim', 'c', 'cpp' },
}
-- Completion acceptance is handled by blink.cmp's auto_brackets, not cmp events.
