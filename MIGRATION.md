# Full Kickstart migration

## Baseline and scope

- Config: `/Users/vincentfaure/.config/nvim`; Neovim `v0.12.5`.
- Full pre-migration backup, including Git and uncommitted work: `/Users/vincentfaure/.config/nvim-backup-20260912-231849`.
- Original HEAD remains `93c190e625c4db34960b864372c2fa72a9d0eb21`. No reset, commit, push, or branch change.
- Upstream basis: `nvim-lua/kickstart.nvim` master at `748f67f49dd9fed47686d1d15e8566d2cba8ed35`; merge-base `4120893b8a1f31a0957f2f891f7fbef73ddfb9b1`.
- Read local configuration, uncommitted changes, and upstream files before porting. Original diff is in `.migration/baseline.diff`.
- `AGENTS.md`, both `.DS_Store` files, and the already-modified `lazy-lock.json` remain byte-identical to the backup. The commented-out Arduino board-picker draft remains unchanged and disabled.
- No changes were made in `odin-ui`. Existing Lazy plugins and Mason installations were not deleted or updated by the migration. Plugin downloads/builds and test outputs are under ignored `.migration/` directories.

## Preserved behavior and coverage

| Area | Migration and checks |
| --- | --- |
| Options and core maps | Space leaders, Nerd Font, relative numbers, clipboard, undo, mouse, timing, splits, whitespace, scrolloff, arrow warnings, Alt-j/k in three modes, terminal escape, window navigation, source/save map retained. VSCode still bypasses plugins. Options and maps asserted. |
| Diagnostics | Inline bullet/spacing, insert-mode updates, underlines, severity sorting, custom icons and de/dq maps retained. Fixed the accidentally nested sign-text table. Kept old diagnostic-jump behavior rather than upstream's automatic float. |
| Themes and mini | Rose Pine Moon active; Catppuccin Frappe options/highlight overrides and Tokyo Night available; corrected Catppuccin's `flavour` option spelling. Existing mini.ai an/in, surround and statusline retained. Palette and module checks passed. Sleuth retained instead of guess-indent; real web-devicons retained instead of the mini.icons mock. |
| Search and Git | All original Telescope searches, home search, dropdowns, FZF, UI-select, hunk maps, undo staging, deleted-line toggle, blame and HEAD diff retained. Map and FZF checks passed. |
| LSP | Native `vim.lsp.config/enable`, Mason v2, blink capabilities and lazydev. All 20 server configs validated: clangd, gopls, rust_analyzer, html, jsonls, cssls, htmx, lemminx, ts_ls, lua_ls, zls, ols, arduino_language_server, marksman, eslint, glsl_analyzer, intelephense, svelte, tailwindcss, yamlls. Arduino CLI config, FQBN and semantic-token exclusions retained. Original buffer-local LSP maps and upstream maps coexist. LuaLS and LemMinX actually attached and initialized. Delve moved from the invalid LSP list to the tool/debugger list. |
| Formatting and lint | StyLua for Lua; save-time LSP fallback except C/C++; manual async format retained. Actual save formatting and C/C++ policy checks passed. Markdownlint and its existing events retained. |
| Completion and Copilot | blink.cmp replaces nvim-cmp; blink-copilot replaces copilot-cmp. LSP, path, LuaSnip, friendly-snippets, lazydev and Copilot providers active. Original Ctrl-n/p/y/Space/b/f/l/h commands configured; no new Tab/Enter acceptance mapping. Configuration/provider checks do not establish completion acceptance or live Copilot suggestion parity. Copilot suggestion/panel remain disabled because completion uses the provider. Health confirmed existing authentication. LuaSnip regex build passed. |
| Treesitter | Main-branch install API, FileType highlighting/indentation, auto-install, and PackChanged updates. All 21 distinct original parser choices load, plus upstream diff/query, Odin and parser dependencies. Ruby regex highlighting and indentation exclusion retained. Autotag explicitly configured. |
| Pairing | Converted bundled autopairs to real setup. Corrected the old unused `disable_file` option to `disable_filetype` for TelescopePrompt, Zig, Odin, Vim, C and C++. Matching blink bracket exclusions apply. Acceptance uses blink brackets rather than obsolete cmp events. |
| Navigation and UI | Neo-tree root/cwd/git/buffer explorers, hidden files, watchers, follow-current-file, clipboard Y, system-open O, lazygit refresh, Harpoon 2 and slots 1–5 retained. Noice routes/presets/maps, Notify options, Dressing and Trouble configured. Explorer, Harpoon and DAP UI opened/closed headlessly. |
| OpenCode | Snacks terminal retained. Existing maps ported to `select()`, `@this`, dotted command IDs and `messages.copy` for the last assistant message. Verified current plugin docs and OpenCode TUI source. API/map checks passed without starting an OpenCode session. |
| Debugging | Bundled Go/DAP UI plus personal maps, signs, virtual text, C, Go, Zig and Odin configs retained. No masked setup errors. codelldb resolves PATH then Mason at launch; deferred program/cwd functions preserved. Tests changed cwd and verified executable-only Zig selection. C resolves lldb-dap/lldb-vscode, with Xcode fallback instead of the missing `/usr/bin/lldb-vscode`. A compiled C fixture launched through the Zig codelldb config and stopped at entry. |

## Loading and versions

`init.lua` follows upstream's sectioned vim.pack configuration. Custom modules use explicit `vim.pack.add()` and setup calls, not a Lazy-spec compatibility layer. Dependencies load before setup; native LSP configs precede buffer loading. Noice sets up after VimEnter. Debugger overrides run after bundled Go setup; Mason handlers cannot asynchronously overwrite them.

`nvim-pack-lock.json` records all **48 plugin revisions** and is not ignored. A second completely empty XDG data/state/cache environment restored every revision from that lockfile and rebuilt FZF/LuaSnip successfully. `lazy-lock.json` is historical only. Lazy and the five cmp-era plugins are not loaded; their old installations remain available for rollback.

Plugin updates: `:lua vim.pack.update()`; review and `:write` to apply. Inspection without fetching: `:lua vim.pack.update(nil, { offline = true })`. Build hooks cover FZF, LuaSnip and Treesitter. The Treesitter plugin revision pins its parser sources; Mason tools are not version-locked by vim.pack.

## Tests and results

All commands ran from the config directory. `.migration/test.sh` sets isolated XDG data/state/cache, disables automatic Mason tool installation through `vim.g.migration_test`, and approves authorized plugin downloads. Integration tests only add existing Mason binaries to PATH.

| Command/check | Result |
| --- | --- |
| `bash .migration/test.sh` with a delayed `qa!` | Clean headless bootstrap; plugins and parsers built. Log: `.migration/startup.log`. |
| `bash .migration/run-check.sh parity`, `cquit` on failure | PASS. Options, maps, 20 LSP configs, completion configuration only, 27 installed parsers after XML auto-install, DAP resolution/prompts, UI APIs, Lua syntax, Git mappings and all 48 lock revisions. `.migration/parity-result.txt`. |
| `cc -g -O0 .migration/fixtures/debug-fixture.c -o .migration/fixtures/debug-fixture` | PASS using existing compiler. |
| `bash .migration/run-check.sh integration` with existing Mason bin PATH | PASS. LuaLS, LemMinX, actual StyLua save, C/C++ policy and real codelldb initialized/stopped. `.migration/integration-result.txt`. |
| Empty `.migration/fresh/{data,state,cache}` bootstrap from lockfile | PASS; exact revisions and native builds. `.migration/fresh-result.txt`, `.migration/fresh.log`. |
| `--cmd 'lua vim.g.vscode = true'` startup | PASS; no plugin setup, personal options retained. `.migration/vscode-result.txt`. |
| `:checkhealth kickstart vim.lsp mason blink.cmp nvim-treesitter copilot opencode` | No errors; details in `.migration/health.txt`. |
| Existing Mason `stylua --check init.lua lua` | PASS, StyLua 2.5.2 and original formatting policy. |
| `git diff --check`; Lua `loadfile` on config files | PASS. |
| Backup byte comparisons and `git rev-parse HEAD` | PASS; protected baseline files unchanged and original HEAD retained. |

The test scripts and logs are retained in ignored `.migration/`. They contain absolute local paths and should not be published as-is.

## Final review fixes and verification

The independent review found four regressions. A new `.migration/review.lua` reproduced all four before the fixes, with exit status 1. The same test now passes.

- Restored explicit Blink-capable activation for `glsl_analyzer`, `intelephense`, `svelte`, `tailwindcss`, and `yamlls`.
- Restored Mason DAP default launch/attach configurations for C++, Rust, and Swift. The handler excludes personal C/Go/Odin/Zig configurations and preserves existing adapters on late install callbacks. Delve remains owned by dap-go and the personal setup.
- Made `custom.options` return an application function, called on every `init.lua` source. Personal diagnostic bullets, spacing, and insert-mode updates now survive reload.
- Disabled Blink automatic signature help; retained Noice automatic signature help.
- Made failed LemMinX initialization an assertion failure instead of a passing limitation message.
- Expanded parity to 20 servers. Review checks also enumerate the existing Mason package directory, check LSP activation and snippet capabilities, and invoke real Mason DAP mappings through the configured handlers. StyLua remains a formatter, not an additional LSP. No tools were installed for these inventory checks.

Final checks, using isolated `.migration/test/{data,state,cache}` and disabled automatic Mason installation:

| Check | Final result |
| --- | --- |
| `bash .migration/run-check.sh review` | PASS. Installed LSP inventory, C++/Rust/Swift launch and attach configs, protected personal DAP configs/adapter, single automatic signature provider, full init reload diagnostics. |
| `bash .migration/run-check.sh parity` | PASS. 20 LSP configs, options/maps, completion configuration, parser loading, DAP/UI checks, and all 48 lockfile revisions. |
| Fixture compilation and `bash .migration/run-check.sh integration` | PASS. LuaLS and LemMinX attached and initialized, actual StyLua save, C/C++ formatting policy, live codelldb initialized and stopped at entry. |
| Delayed isolated headless startup | PASS. 48 loaded plugins, no Lazy, empty `vim.v.errmsg`. `.migration/final-startup-status.txt`. |
| Isolated VSCode startup and reload | PASS. Personal diagnostics retained, Blink not loaded, empty `vim.v.errmsg`. `.migration/final-vscode-status.txt`. |
| Existing Mason StyLua `--check init.lua lua`; `git diff --check` | PASS. |
| Full backup SHA-256 inventory before/after finalization | PASS. All 156 file contents/symlink targets unchanged. Protected config files still match the backup; HEAD unchanged. |

Exact source/report/test-script files changed during this finalization pass:

- `init.lua`
- `lua/custom/options.lua`
- `lua/custom/plugins/lsps.lua`
- `lua/kickstart/plugins/debug.lua`
- `MIGRATION.md`
- `.migration/integration.lua`
- `.migration/parity.lua`
- `.migration/run-check.sh`
- `.migration/review.lua`, new regression test

Generated test logs, statuses, fixtures and isolated runtime caches remain under ignored `.migration/`. The pre-fix result is `.migration/review-before-status.txt`; final results are `.migration/{review,parity,integration}-status.txt` and `.migration/integration-result.txt`. The full migration file list is below.

This pass reused the existing isolated plugin installation. It did not repeat the earlier empty-directory network bootstrap or full health suite. No nested workflows/sessions, commits, pushes, backup writes, old plugin-data deletion, or `odin-ui` edits were performed.

## Limitations and next launch

- Open Neovim normally and approve vim.pack's first-install prompt. It will install the locked plugins into the normal data directory and compile parsers. Tests deliberately did not populate or clean that directory.
- Existing Mason tools and Copilot credentials should be reused. No reauthentication was needed in testing. No unrelated language toolchains were installed.
- Health warnings about absent LSP executables came from the empty test Mason directory. Integration tests using existing tools successfully ran LuaLS and LemMinX. Missing Java/PHP/Composer/Julia are general Mason health warnings, not reasons to install them for this migration.
- Blink's missing Rust matcher warning is expected: upstream's Lua matcher is selected. Copilot's disabled suggestion warning is expected. Snacks input/picker remain disabled so Dressing/Telescope keep their existing behavior.
- Completion acceptance, snippet expansion through completion acceptance, and live Copilot suggestions have not been tested end to end. Authentication and provider construction alone do not establish parity. On first launch, check Ctrl-Space/Ctrl-n/Ctrl-y acceptance, snippet jumps, and an authenticated Copilot suggestion in a suitable file.
- The hardcoded Go Delve path and overlapping `<leader>ds` maps predate this migration and remain unchanged.
- Headless UI checks do not establish visual parity in the terminal. Other language servers were configuration-checked, not exercised against real projects. Arduino hardware, actual Odin/Zig programs, Go debugging, and remote OpenCode conversations were not run.
- Gitsigns still provides the deprecated undo-stage and deleted-line APIs. They remain mapped to preserve behavior at the locked revision.
- `AGENTS.md` still documents Lazy by request. Follow this report and current Lua files for the migrated architecture.

## Changed files

- Rebased and customized `init.lua`; updated `README.md` and `.gitignore`.
- Added `lua/custom/options.lua`, `lua/custom/plugins/{theme,formatting,opencode}.lua`, `nvim-pack-lock.json`, and this report.
- Ported `lua/custom/plugins/{init,lsps,dap,file-exploration}.lua` and `lua/custom/plugins/after/dapconf.lua`.
- Updated `lua/kickstart/health.lua` and bundled `plugins/{autopairs,debug,indent_line,lint,neo-tree}.lua`. Removed the old gitsigns module after moving its behavior into upstream's `init.lua` setup.
- Updated upstream `.github/ISSUE_TEMPLATE/bug_report.md` and `.github/workflows/stylua.yml`; added `.github/ISSUE_TEMPLATE/config.yml`. Upstream help files/license were checked and are unchanged.
- `.DS_Store` and `lazy-lock.json` still appear modified against HEAD because they were already modified before migration, not because this migration changed them.
