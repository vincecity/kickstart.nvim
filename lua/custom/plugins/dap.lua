---@param config {args?:string[]|fun():string[]?}
local function get_args(config)
  local args = type(config.args) == 'function' and (config.args() or {}) or config.args or {}
  config = vim.deepcopy(config)
  ---@cast args string[]
  config.args = function()
    local new_args = vim.fn.input('Run with args: ', table.concat(args, ' ')) --[[@as string]]
    return vim.split(vim.fn.expand(new_args) --[[@as string]], ' ')
  end
  return config
end

vim.pack.add { 'https://github.com/theHamsta/nvim-dap-virtual-text' }
require('nvim-dap-virtual-text').setup {}
require 'custom.plugins.after.dapconf'
vim.keymap.set('n', '<leader>du', function()
  require('dapui').toggle {}
end, { desc = 'Dap UI' })
vim.keymap.set({ 'n', 'v' }, '<leader>dev', function()
  require('dapui').eval()
end, { desc = 'Eval' })
local keys = {
  {
    '<leader>dB',
    function()
      require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end,
    desc = 'Breakpoint Condition',
  },
  {
    '<leader>db',
    function()
      require('dap').toggle_breakpoint()
    end,
    desc = 'Toggle Breakpoint',
  },
  {
    '<leader>dc',
    function()
      require('dap').continue()
    end,
    desc = 'Continue',
  },
  {
    '<leader>da',
    function()
      require('dap').continue { before = get_args }
    end,
    desc = 'Run with Args',
  },
  {
    '<leader>dC',
    function()
      require('dap').run_to_cursor()
    end,
    desc = 'Run to Cursor',
  },
  {
    '<leader>dg',
    function()
      require('dap').goto_()
    end,
    desc = 'Go to Line (No Execute)',
  },
  {
    '<leader>di',
    function()
      require('dap').step_into()
    end,
    desc = 'Step Into',
  },
  {
    '<leader>dj',
    function()
      require('dap').down()
    end,
    desc = 'Down',
  },
  {
    '<leader>dk',
    function()
      require('dap').up()
    end,
    desc = 'Up',
  },
  {
    '<leader>dl',
    function()
      require('dap').run_last()
    end,
    desc = 'Run Last',
  },
  {
    '<leader>do',
    function()
      require('dap').step_out()
    end,
    desc = 'Step Out',
  },
  {
    '<leader>dO',
    function()
      require('dap').step_over()
    end,
    desc = 'Step Over',
  },
  {
    '<leader>dp',
    function()
      require('dap').pause()
    end,
    desc = 'Pause',
  },
  {
    '<leader>dr',
    function()
      require('dap').repl.toggle()
    end,
    desc = 'Toggle REPL',
  },
  {
    '<leader>ds',
    function()
      require('dap').session()
    end,
    desc = 'Session',
  },
  {
    '<leader>dt',
    function()
      require('dap').terminate()
    end,
    desc = 'Terminate',
  },
  {
    '<leader>dw',
    function()
      require('dap.ui.widgets').hover()
    end,
    desc = 'Widgets',
  },
}
for _, key in ipairs(keys) do
  vim.keymap.set('n', key[1], key[2], { desc = key.desc })
end
local dap_signs = {
  Stopped = { '󰁕 ', 'DiagnosticWarn', 'DapStoppedLine' },
  Breakpoint = ' ',
  BreakpointCondition = ' ',
  BreakpointRejected = { ' ', 'DiagnosticError' },
  LogPoint = '.>',
}
vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })

for name, sign in pairs(dap_signs) do
  sign = type(sign) == 'table' and sign or { sign }
  vim.fn.sign_define('Dap' .. name, { text = sign[1], texthl = sign[2] or 'DiagnosticInfo', linehl = sign[3], numhl = sign[3] })
end
