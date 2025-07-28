local dap = require 'dap'
dap.adapters.delve = {
  type = 'server',
  port = '${port}',
  executable = {
    command = '/opt/homebrew/bin/dlv',
    args = { 'dap', '-l', '127.0.0.1:${port}' },
    -- add this if on windows, otherwise server won't open successfully
    -- detached = false
  },
}
-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
  {
    type = 'delve',
    name = 'Debug',
    request = 'launch',
    program = '${file}',
  },
  {
    type = 'delve',
    name = 'Debug test', -- configuration for debugging test files
    request = 'launch',
    mode = 'test',
    program = '${file}',
  },
  -- works with go.mod packages and sub packages
  {
    type = 'delve',
    name = 'Debug test (go.mod)',
    request = 'launch',
    mode = 'test',
    program = './${relativeFileDirname}',
  },
}
dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb-vscode', -- or wherever lldb-vscode is
  name = 'lldb',
}

dap.configurations.c = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
  },
}
