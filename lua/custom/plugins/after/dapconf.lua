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

local function get_odin_path()
  local bin_dir = vim.fn.getcwd() .. '/bin'
  return vim.fn.input('Path to executable: ', bin_dir .. '/', 'file')
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

dap.adapters.lldb = function(callback)
  local command = vim.fn.exepath 'lldb-dap'
  if command == '' then
    command = vim.fn.exepath 'lldb-vscode'
  end
  if command == '' and vim.fn.executable 'xcrun' == 1 then
    local result = vim.system({ 'xcrun', '--find', 'lldb-dap' }, { text = true }):wait()
    if result.code == 0 then
      command = vim.trim(result.stdout)
    end
  end
  if command == '' then
    vim.notify('lldb-dap not found. Install the Xcode command line tools or put lldb-dap on PATH.', vim.log.levels.ERROR)
    return
  end
  callback { type = 'executable', command = command, name = 'lldb' }
end

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

local function resolve_codelldb()
  local mason_path = require('mason.settings').current.install_root_dir .. '/bin/codelldb'
  local exepath = vim.fn.exepath 'codelldb'

  if exepath ~= '' then
    return exepath
  end

  if vim.fn.executable(mason_path) == 1 then
    return mason_path
  end

  return nil
end

-- Resolve at launch, so installing codelldb with Mason needs no restart.
dap.adapters.codelldb = function(callback)
  local codelldb_path = resolve_codelldb()
  if not codelldb_path then
    vim.notify('codelldb executable not found. Install it with :MasonInstall codelldb.', vim.log.levels.ERROR)
    return
  end
  callback {
    type = 'server',
    port = '${port}',
    executable = {
      command = codelldb_path,
      args = { '--port', '${port}' },
      detached = false,
    },
  }
end

dap.configurations.zig = {
  {
    type = 'codelldb',
    name = 'Launch Zig executable',
    request = 'launch',
    program = getpath,
    cwd = function()
      return vim.fn.getcwd()
    end,
    stopOnEntry = false,
  },
}

dap.configurations.odin = {
  {
    type = 'codelldb',
    name = 'Launch Odin executable',
    request = 'launch',
    program = get_odin_path,
    cwd = function()
      return vim.fn.getcwd()
    end,
    stopOnEntry = false,
  },
}
