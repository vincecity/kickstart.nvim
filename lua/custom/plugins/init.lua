-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'vincecity/vim-arduino',
    ft = { 'arduino' },
    event = { 'BufEnter' },
  },

  {
    'ziglang/zig.vim',
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'main',
    dependencies = {
      -- { 'zbirenbaum/copilot.lua' }, -- Already configured in lsps.lua
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    opts = {
      debug = false, -- Enable debugging
      model = 'claude-sonnet-4',
      -- See Configuration section for rest
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}
