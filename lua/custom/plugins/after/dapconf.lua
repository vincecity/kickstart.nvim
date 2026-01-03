local dap = require 'dap'

local function getpath()
  local bin_dir = vim.fn.getcwd() .. '/zig-out/bin'
  local files = vim.fn.glob(bin_dir .. '/*', false, true)
  local executables = vim.tbl_filter(function(f)
    return vim.fn.executable(f) == 1 -- FIXED: use executable() instead
  end, files)
  local default = executables[1] or (bin_dir .. '/')
  return vim.fn.input('Path to executable: ', default, 'file')
end

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
    cwd = function() -- FIXED: use function instead of ${workspaceFolder}
      return vim.fn.getcwd()
    end,
    stopOnEntry = false,
    args = {},
  },
}

dap.adapters.codelldb = {
  type = 'executable',
  port = '${port}',
  executable = {
    command = vim.fn.expand '~/.local/share/nvim/mason/bin/codelldb',
    args = { '--port', '${port}' },
  },
}

dap.configurations.zig = {
  {
    type = 'codelldb',
    name = 'Launch Zig executable',
    request = 'launch',
    program = getpath(),
    cwd = function()
      return vim.fn.getcwd()
    end,
    stopOnEntry = false,
  },
}
