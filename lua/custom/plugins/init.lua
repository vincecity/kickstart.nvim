-- Explicit order: shared dependencies and UI, then custom debugger overrides.
vim.pack.add {
  'https://github.com/vincecity/vim-arduino',
  'https://github.com/ziglang/zig.vim',
  'https://github.com/windwp/nvim-ts-autotag',
}
require('nvim-ts-autotag').setup {}
require 'custom.plugins.file-exploration'
require 'custom.plugins.opencode'
require 'custom.plugins.dap'
vim.keymap.set('n', '<leader>sF', function()
  require('telescope.builtin').find_files { cwd = '~' }
end, { desc = '[S]earch home [F]iles' })
require('which-key').add {
  { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
  { '<leader>d', group = '[D]ebug / document' },
  { '<leader>r', group = '[R]ename' },
  { '<leader>w', group = '[W]orkspace' },
}
