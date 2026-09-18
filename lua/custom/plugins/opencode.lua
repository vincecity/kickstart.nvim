vim.pack.add {
  { src = 'https://github.com/nickjvandyke/opencode.nvim', version = vim.version.range '*' },
  'https://github.com/folke/snacks.nvim',
}
require('snacks').setup {}
local command = 'opencode --port'
local terminal = { win = { position = 'right', enter = false } }
vim.g.opencode_opts = {
  server = {
    start = function()
      require('snacks.terminal').open(command, terminal)
    end,
  },
}
vim.keymap.set('n', '<leader>ot', function()
  require('snacks.terminal').toggle(command, terminal)
end, { desc = 'Toggle embedded opencode' })
vim.keymap.set('n', '<leader>oa', function()
  require('opencode').ask()
end, { desc = 'Ask opencode' })
vim.keymap.set('v', '<leader>oa', function()
  require('opencode').ask '@this: '
end, { desc = 'Ask opencode about selection' })
vim.keymap.set({ 'n', 'v' }, '<leader>op', function()
  require('opencode').select()
end, { desc = 'Select prompt' })
for key, action in pairs {
  ['<leader>on'] = 'session.new',
  ['<leader>oy'] = 'messages.copy',
  ['<S-C-u>'] = 'session.half.page.up',
  ['<S-C-d>'] = 'session.half.page.down',
} do
  vim.keymap.set('n', key, function()
    require('opencode').command(action)
  end, { desc = 'OpenCode: ' .. action })
end
