-- Reapply personal options and maps when init.lua is sourced again.
return function()
  --  See `:help vim.keymap.set()`

  -- Clear highlights on search when pressing <Esc> in normal mode
  --  See `:help hlsearch`
  vim.opt.hlsearch = true
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
  vim.keymap.set('n', '<leader>so', ':update<CR> :source<CR>')
  -- [[ Diagnostic Options ]]
  -- Optional: Change the appearance of the signs in the gutter
  -- These icons depend on your Nerd Font, which you have enabled.
  local signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN] = ' ',
      [vim.diagnostic.severity.HINT] = ' ',
      [vim.diagnostic.severity.INFO] = ' ',
    },
  }
  vim.diagnostic.config {
    jump = { on_jump = function() end },
    -- Show signs in the sign column (gutter)
    signs = {
      text = signs.text,
      -- Use the default sign column, which is the left side of the window
      --  See `:help vim.diagnostic.signs`
      priority = 20, -- Set a priority for the signs
    },
    -- Show diagnostics as virtual text (inline)
    virtual_text = {
      spacing = 4, -- Add some space for readability
      prefix = '●', -- Or '▎', '■', '→'
    },
    -- Underline the code with the diagnostic
    underline = true,
    -- Update diagnostics while in insert mode
    update_in_insert = true,
    -- Severity sort puts errors first
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
  }

  -- Diagnostic keymaps
  vim.keymap.set('n', '[d', function()
    vim.diagnostic.jump { count = -1 }
  end, { desc = 'Go to previous [D]iagnostic message' })
  vim.keymap.set('n', ']d', function()
    vim.diagnostic.jump { count = 1 }
  end, { desc = 'Go to next [D]iagnostic message' })
  vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
  vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

  -- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
  -- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
  -- is not what someone will guess without a bit more experience.
  --
  -- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
  -- or just use <C-\><C-n> to exit terminal mode
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  -- TIP: Disable arrow keys in normal mode
  vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
  vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
  vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
  vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

  -- Move Lines
  vim.keymap.set('n', '<A-j>', '<cmd>m .+1<cr>==', { desc = 'Move Down' })
  vim.keymap.set('n', '<A-k>', '<cmd>m .-2<cr>==', { desc = 'Move Up' })
  vim.keymap.set('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Down' })
  vim.keymap.set('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Up' })
  vim.keymap.set('v', '<A-j>', ":m '>+1<cr>gv=gv", { desc = 'Move Down' })
  vim.keymap.set('v', '<A-k>', ":m '<-2<cr>gv=gv", { desc = 'Move Up' })

  -- Keybinds to make split navigation easier.
  --  Use CTRL+<hjkl> to switch between windows
  --
  --  See `:help wincmd` for a list of all window commands
  vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
  vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
  vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
  vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
end
