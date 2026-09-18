vim.pack.add {
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/folke/trouble.nvim',
  'https://github.com/rcarriga/nvim-notify',
  'https://github.com/folke/noice.nvim',
  'https://github.com/stevearc/dressing.nvim',
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = 'v3.x' },
  { src = 'https://github.com/ThePrimeagen/harpoon', version = 'harpoon2' },
}
local function maps(keys)
  for _, key in ipairs(keys) do
    vim.keymap.set(key.mode or 'n', key[1], key[2], { desc = key.desc, silent = key.silent, expr = key.expr })
  end
end
require('trouble').setup {}
require('dressing').setup {}
require('notify').setup {
  stages = 'static',
  timeout = 3000,
  max_height = function()
    return math.floor(vim.o.lines * 0.75)
  end,
  max_width = function()
    return math.floor(vim.o.columns * 0.75)
  end,
  on_open = function(win)
    vim.api.nvim_win_set_config(win, { zindex = 100 })
  end,
}
maps {
  {
    '<leader>un',
    function()
      require('notify').dismiss { silent = true, pending = true }
    end,
    desc = 'Dismiss All Notifications',
  },
}
-- Noice attaches UI handlers after startup; no fictional VeryLazy event.
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    vim.schedule(function()
      require('noice').setup {
        lsp = {
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
          },
        },
        routes = {
          {
            filter = {
              event = 'msg_show',
              any = {
                { find = '%d+L, %d+B' },
                { find = '; after #%d+' },
                { find = '; before #%d+' },
              },
            },
            view = 'mini',
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = true,
        },
      }
    end)
  end,
})
maps {
  {
    '<S-Enter>',
    function()
      require('noice').redirect(vim.fn.getcmdline())
    end,
    mode = 'c',
    desc = 'Redirect Cmdline',
  },
  {
    '<leader>snl',
    function()
      require('noice').cmd 'last'
    end,
    desc = 'Noice Last Message',
  },
  {
    '<leader>snh',
    function()
      require('noice').cmd 'history'
    end,
    desc = 'Noice History',
  },
  {
    '<leader>sna',
    function()
      require('noice').cmd 'all'
    end,
    desc = 'Noice All',
  },
  {
    '<leader>snd',
    function()
      require('noice').cmd 'dismiss'
    end,
    desc = 'Dismiss All',
  },
  {
    '<c-f>',
    function()
      if not require('noice.lsp').scroll(4) then
        return '<c-f>'
      end
    end,
    silent = true,
    expr = true,
    desc = 'Scroll Forward',
    mode = { 'i', 'n', 's' },
  },
  {
    '<c-b>',
    function()
      if not require('noice.lsp').scroll(-4) then
        return '<c-b>'
      end
    end,
    silent = true,
    expr = true,
    desc = 'Scroll Backward',
    mode = { 'i', 'n', 's' },
  },
}
require('neo-tree').setup {
  sources = { 'filesystem', 'buffers', 'git_status', 'document_symbols' },
  open_files_do_not_replace_types = { 'terminal', 'Trouble', 'trouble', 'qf', 'Outline' },
  filesystem = {
    hijack_netrw_behavior = 'disabled', --"open_default", -- "open_current", -- "disabled",
    filtered_items = {
      visible = true,
    },
    bind_to_cwd = false,
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
  },
  window = {
    mappings = {
      ['<space>'] = 'none',
      ['Y'] = {
        function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          vim.fn.setreg('+', path, 'c')
        end,
        desc = 'Copy Path to Clipboard',
      },
      ['O'] = {
        function(state)
          vim.ui.open(state.tree:get_node().path)
        end,
        desc = 'Open with System Application',
      },
    },
  },
  default_component_configs = {
    indent = {
      with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = '',
      expander_expanded = '',
      expander_highlight = 'NeoTreeExpander',
    },
  },
}
maps {
  {
    '<leader>E',
    function()
      require('neo-tree.command').execute { toggle = true, dir = '/' }
    end,
    desc = 'Explorer NeoTree (Root Dir)',
  },
  {
    '<leader>e',
    function()
      require('neo-tree.command').execute { toggle = true, dir = vim.uv.cwd() }
    end,
    desc = 'Explorer NeoTree (cwd)',
  },
  {
    '<leader>ge',
    function()
      require('neo-tree.command').execute { source = 'git_status', toggle = true }
    end,
    desc = 'Git Explorer',
  },
  {
    '<leader>be',
    function()
      require('neo-tree.command').execute { source = 'buffers', toggle = true }
    end,
    desc = 'Buffer Explorer',
  },
}
vim.api.nvim_create_autocmd('TermClose', {
  pattern = '*lazygit',
  callback = function()
    if package.loaded['neo-tree.sources.git_status'] then
      require('neo-tree.sources.git_status').refresh()
    end
  end,
})
require('harpoon'):setup {
  menu = {
    width = vim.api.nvim_win_get_width(0) - 4,
  },
  settings = {
    save_on_toggle = true,
  },
}
do
  local keys = {
    {
      '<leader>H',
      function()
        require('harpoon'):list():add()
      end,
      desc = 'Harpoon File',
    },
    {
      '<leader>h',
      function()
        local harpoon = require 'harpoon'
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = 'Harpoon Quick Menu',
    },
  }

  for i = 1, 5 do
    table.insert(keys, {
      '<leader>' .. i,
      function()
        require('harpoon'):list():select(i)
      end,
      desc = 'Harpoon to File ' .. i,
    })
  end

  maps(keys)
end
