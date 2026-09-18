vim.pack.add {
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  'https://github.com/folke/lazydev.nvim',
  'https://github.com/Bilal2453/luvit-meta',
  'https://github.com/zbirenbaum/copilot.lua',
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.*' },
}
require('lazydev').setup { library = { { path = 'luvit-meta/library', words = { 'vim%.uv' } } } }
require('copilot').setup { suggestion = { enabled = false }, panel = { enabled = false } }
require('mason').setup {}
require('mason-lspconfig').setup { automatic_enable = false }
local servers = {
  clangd = {},
  gopls = {},
  -- Previously activated automatically from the installed Mason servers.
  glsl_analyzer = {},
  intelephense = {},
  svelte = {},
  tailwindcss = {},
  yamlls = {},
  --pyright = {},
  rust_analyzer = {},
  html = {},
  jsonls = {},
  cssls = {},
  htmx = {},
  lemminx = {},
  -- Some languages (like typescript) have entire language plugins that can be useful:
  --    https://github.com/pmizio/typescript-tools.nvim
  --
  -- But for many setups, the LSP (`ts_ls`) will work just fine
  ts_ls = {},
  --

  lua_ls = {
    -- cmd = {...},
    -- filetypes = { ...},
    -- capabilities = {},
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
        -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
        -- diagnostics = { disable = { 'missing-fields' } },
      },
    },
  },
  zls = {},
  ols = {},
  arduino_language_server = {
    cmd = {
      'arduino-language-server',
      '-cli-config',
      '/Users/vincentfaure/Documents/Arduino/arduino-cli.yaml',
      '-fqbn',
      'arduino:samd:nano_33_iot',
    },
    capabilities = {
      textDocument = {
        semanticTokens = vim.NIL,
      },
      workspace = {
        semanticTokens = vim.NIL,
      },
    },
    filetypes = { 'arduino' },
  },
  marksman = {},
  eslint = {},
}
local tools = vim.tbl_keys(servers)
vim.list_extend(tools, { 'stylua', 'delve' })
-- Tests may disable tool installation without touching the normal Mason directory.
require('mason-tool-installer').setup { ensure_installed = tools, run_on_start = not vim.g.migration_test }
local capabilities = require('blink.cmp').get_lsp_capabilities()
for name, server in pairs(servers) do
  server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('custom-lsp-keymaps', { clear = true }),
  callback = function(event)
    local builtin = require 'telescope.builtin'
    local maps = {
      gd = { builtin.lsp_definitions, '[G]oto [D]efinition' },
      gr = { builtin.lsp_references, '[G]oto [R]eferences' },
      gI = { builtin.lsp_implementations, '[G]oto [I]mplementation' },
      ['<leader>D'] = { builtin.lsp_type_definitions, 'Type [D]efinition' },
      ['<leader>ds'] = { builtin.lsp_document_symbols, '[D]ocument [S]ymbols' },
      ['<leader>ws'] = { builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols' },
      ['<leader>rn'] = { vim.lsp.buf.rename, '[R]e[n]ame' },
      gD = { vim.lsp.buf.declaration, '[G]oto [D]eclaration' },
    }
    for key, action in pairs(maps) do
      vim.keymap.set('n', key, action[1], { buffer = event.buf, desc = 'LSP: ' .. action[2] })
    end
    vim.keymap.set({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = event.buf, desc = 'LSP: [C]ode [A]ction' })
  end,
})
