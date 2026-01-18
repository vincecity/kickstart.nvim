# AGENTS.md - Neovim Configuration

Guidance for AI agents working with this kickstart.nvim-based Neovim configuration.

## Project Structure

```
~/.config/nvim/
├── init.lua                     # Main entry point (~700 lines)
├── lua/
│   ├── custom/plugins/          # User customizations (add plugins here)
│   │   ├── init.lua             # Custom plugin entry
│   │   ├── lsps.lua             # LSP, Mason, Conform, nvim-cmp, Copilot
│   │   ├── dap.lua              # Debug adapter protocol setup
│   │   ├── file-exploration.lua # Neo-tree, Harpoon, Noice, Trouble
│   │   └── after/               # Post-load configurations
│   └── kickstart/plugins/       # Base kickstart modules
├── .stylua.toml                 # Lua formatter configuration
└── lazy-lock.json               # Plugin version lockfile
```

## Build/Lint/Test Commands

```bash
stylua .              # Format all Lua files (required before commits)
stylua --check .      # Check formatting without modifying
```

```vim
:checkhealth        " Check configuration health
:Lazy               " View/manage plugins
:Mason              " Manage LSP servers
:source %           " Reload current file
```

**CI:** `.github/workflows/stylua.yml` runs `stylua --check .` on pull requests.

## Code Style Guidelines

### StyLua Configuration (`.stylua.toml`)
```toml
column_width = 160
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferSingle"
call_parentheses = "None"
```

### Lua Conventions

**Indentation:** 2 spaces (not tabs)

**Quotes:** Single quotes preferred: `vim.g.mapleader = ' '`

**Function Calls:** Omit parentheses for single string/table argument
```lua
require 'dap'
vim.fn.stdpath 'data'
vim.cmd [[Neotree close]]
```

**Tables:** Use spaces inside braces: `{ 'n', 'v' }`

**Comments:** Use standard prefixes
```lua
-- NOTE: Important information
-- WARN: Warning about potential issues
-- TODO: Task to be completed
-- stylua: ignore  -- Disable formatting for next construct
---@diagnostic disable-next-line: duplicate-set-field
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Local variables | snake_case | `local builtin`, `local lazypath` |
| Functions | snake_case | `get_args`, `check_version` |
| Autogroups | Descriptive with prefix | `'kickstart-lsp-attach'` |
| Plugin specs | Table with string name | `{ 'folke/trouble.nvim', ... }` |

### Keymap Conventions

Leader key is `<space>`. Use descriptive `desc` with `[X]` mnemonic pattern:
```lua
map('gd', func, '[G]oto [D]efinition')
map('<leader>sf', func, '[S]earch [F]iles')
```

### Plugin Spec Structure (lazy.nvim)
```lua
return {
  {
    'author/plugin-name',
    dependencies = { 'other/plugin' },
    ft = 'lua',                    -- Lazy load on filetype
    event = 'VeryLazy',            -- Lazy load event
    cmd = 'PluginCommand',         -- Lazy load on command
    keys = { { '<leader>x', function() ... end, desc = 'Description' } },
    opts = {},                     -- Options passed to setup()
    config = function(_, opts) require('plugin').setup(opts) end,
  },
}
```

### Error Handling
```lua
if stat and stat.type == 'directory' then require 'neo-tree' end  -- Check nil

local ok, module = pcall(require, 'optional-module')  -- Use pcall
if ok then module.setup() end
```

## Key Architecture Patterns

### Adding New Plugins
1. Create file in `lua/custom/plugins/your-plugin.lua`
2. Return a table (or list of tables) with plugin specs
3. Plugins are auto-imported via `{ import = 'custom.plugins' }` in init.lua

### LSP Configuration
- Mason handles LSP server installation
- Servers configured in `lua/custom/plugins/lsps.lua`
- Use `vim.api.nvim_create_autocmd('LspAttach', ...)` for buffer-local keymaps

**Configured servers:** clangd, gopls, rust_analyzer, lua_ls, zls, ols,
arduino_language_server, ts_ls, html, cssls, jsonls, htmx, eslint, marksman

### Formatting (conform.nvim)
- Format on save enabled (except C/C++)
- StyLua for Lua files
- Configure in `lua/custom/plugins/lsps.lua`

## Important Files

| File | Purpose |
|------|---------|
| `init.lua` | Main config, options, core keymaps, base plugins |
| `lua/custom/plugins/lsps.lua` | LSP, completion, formatting setup |
| `lua/custom/plugins/dap.lua` | Debugger configuration |
| `lua/custom/plugins/file-exploration.lua` | File explorer, navigation |

## Common Patterns
```lua
vim.api.nvim_create_autocmd('EventName', {
  group = vim.api.nvim_create_augroup('unique-group-name', { clear = true }),
  callback = function(event) --[[ Handle event ]] end,
})
```

```lua
vim.keymap.set('n', '<leader>xx', function() --[[ Action ]] end, { desc = 'Description' })
```

## External Dependencies

Required: git, make, unzip, gcc, ripgrep, clipboard tool
Optional: Nerd Font (set `vim.g.have_nerd_font = true` if installed)
