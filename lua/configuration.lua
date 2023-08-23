local conf = {}

-- Namespace to use, currently available namespaces are "free" and "onno"
-- Switching namespace changes to a completely different configuration
-- This is an example of how to incorporate multiple Neovim configurations
-- into a single configuration.
conf.namespace = "free"
--
-- THEME CONFIGURATION
-- Available themes:
--   nightfox, tokyonight, dracula, kanagawa, catppuccin,
--   tundra, onedarkpro, everforest, monokai-pro
-- A configuration file for each theme is in lua/themes/
-- Use <F8> to step through themes
conf.theme = "tokyonight"
-- Available styles are:
--   kanagawa:    wave, dragon, lotus
--   tokyonight:  night, storm, day, moon
--   onedarkpro:  onedark, onelight, onedark_vivid, onedark_dark
--   catppuccin:  latte, frappe, macchiato, mocha, custom
--   dracula:     blood, magic, soft, default
--   nightfox:    carbonfox, dawnfox, dayfox, duskfox, nightfox, nordfox, terafox
--   monokai-pro: classic, octagon, pro, machine, ristretto, spectrum
conf.theme_style = "night"
-- enable transparency if the theme supports it
conf.enable_transparent = true

-- GLOBAL OPTIONS CONFIGURATION
-- Some prefer space as the map leader, but why
conf.mapleader = " "
conf.maplocalleader = " "
-- Toggle global status line
conf.global_statusline = true
-- set numbered lines
conf.number = true
-- enable mouse see :h mouse
conf.mouse = "a"
-- set relative numbered lines
conf.relative_number = true
-- always show tabs; 0 never, 1 only if at least two tab pages, 2 always
conf.showtabline = 2
-- enable or disable listchars
conf.list = true
-- which list chars to show
conf.listchars = {
  eol = "↲",
  tab = "▸ ",
  space = "·",
  trail = "_",
  extends = "◀",
  precedes = "▶",
}
-- use rg instead of grep
conf.grepprg = "rg --hidden --vimgrep --smart-case --"

-- ENABLE/DISABLE/SELECT PLUGINS
--
-- AI coding assistants - ChatGPT, Code Explain, Codeium, Copilot, NeoAI
-- Enable Github Copilot if you have an account, it is superior
--
-- Enable ChatGPT (set OPENAI_API_KEY environment variable)
conf.enable_chatgpt = true
-- Enable Code Explain (requires 3.5GB model, uses GPT4ALL)
conf.enable_codeexplain = true
-- Enable Codeium
conf.enable_codeium = true
-- Enable Github Copilot
conf.enable_copilot = false
-- Enable Neoai, https://github.com/Bryley/neoai.nvim
conf.enable_neoai = false
--
-- Enable display of ascii art
conf.enable_asciiart = true
-- Delete buffers and close files without closing your windows
conf.enable_bbye = true
-- Enable display of custom cheatsheets
conf.enable_cheatsheet = true
-- Enable coding plugins for diagnostics, debugging, and language servers
conf.enable_coding = true
-- Enable compile plugin to compile and run current file
conf.enable_compile = true
-- Enable dressing plugin for improved default vim.ui interfaces
conf.enable_dressing = true
-- Enable easy motions, can be one of "hop", "leap", or "none"
conf.enable_motion = "none"
-- Enable note making using Markdown preview and Obsidian plugins
conf.enable_notes = true
-- If notes enabled, markdown preview to use (preview, peek, none)
conf.markdown_preview = "preview"
-- If notes enabled, Neorg notes folders, multiple folders supported
conf.neorg_notes = {
  -- "~/Documents/Notes/Neorg", -- NEORG_NOTES
  -- "XXXXX", -- NEORG_NOTES
  -- "YYYYY", -- NEORG_NOTES
  -- "ZZZZZ", -- NEORG_NOTES
}
-- Enable note making using Obsidian
conf.enable_obsidian = false
-- If Obsidian enabled, Obsidian vault folder (relative to HOME)
conf.obsidian_vault = "Documents/Notes/Obsidian"
-- Enable renamer plugin for VS Code-like renaming UI
conf.enable_renamer = true
-- Enable ranger in a floating window
conf.enable_ranger_float = true
-- Enable multiple cursors
conf.enable_multi_cursor = true
-- Highlight sections of code which might have security or quality issues
conf.enable_securitree = true
-- neovim session manager to use: persistence, possession, or none
conf.session_manager = "persistence"
-- File explorer tree plugin: neo-tree, nvim-tree, or none
conf.file_tree = "neo-tree"
-- Replace the UI for messages, cmdline and the popupmenu
conf.enable_noice = true
-- Enable the newer rainbow treesitter delimiter highlighting
conf.enable_rainbow2 = false
-- Enable 'StartupTime' command
conf.enable_startuptime = true
-- Add/change/delete surrounding delimiter pairs with ease
conf.enable_surround = true
-- Enable the wilder plugin
conf.enable_wilder = true
--
-- Lualine, Tabline, and Winbar configuration
--
-- The Lualine style can be "free" or "onno"
conf.lualine_style = "free"
-- Separator for 'onno' style lualine components, can be "bubble" or "arrow"
conf.lualine_separator = "arrow"
-- Enable fancy lualine components
conf.enable_fancy = true
-- The statusline (lualine), tabline, and winbar can each be enabled or disabled
-- Enable statusline (lualine)
conf.enable_statusline = true
-- Enable status in tabline
conf.enable_status_in_tab = false
-- Enable winbar with navic location
-- Can be one of "barbecue", "standard", or "none"
-- Barbecue provides a clickable navic location, standard has more info
conf.enable_winbar = "barbecue"
-- Enable LSP progress in winbar
conf.enable_lualine_lsp_progress = true
-- Enable rebelot/terminal.nvim
--
conf.enable_terminal = true
-- Enable toggleterm plugin
conf.enable_toggleterm = true
-- Enable playing games inside Neovim!
conf.enable_games = false
-- Enable the WakaTime metrics dashboard (requires API key)
conf.enable_wakatime = true
-- Enable zen mode distraction-free coding
conf.enable_zenmode = true
-- if zenmode enabled then enable terminal support as well
conf.enable_kitty = false
conf.enable_alacritty = false
conf.enable_wezterm = true
-- Enable a dashboard, can be one of "alpha", "dash", "mini", or "none"
conf.dashboard = "dash"
-- Number of recent files, dashboard header and quick links settings
-- only apply to the Alpha dashboard
-- Number of recent files shown in dashboard
-- 0 disables showing recent files
conf.dashboard_recent_files = 5
-- Enable the header of the dashboard
conf.enable_dashboard_header = true
-- Enable quick links of the dashboard
conf.enable_dashboard_quick_links = true
-- Enable either the Drop screensaver or the Zone screensaver
-- Drop can be one of xmas, stars, leaves, snow, spring, summer, or drop
-- Zone can be one of treadmill, matrix, epilepsy, vanish, or zone
-- 'drop' indicates a random drop, 'zone' a random zone
-- 'random' to randomly select between the two, 'none' to disable
conf.enable_screensaver = "none"
-- Screensaver timeout in minutes
conf.screensaver_timeout = 15
-- Enable the Neovim bookmarks plugin (https://github.com/ldelossa/nvim-ide)
conf.enable_bookmarks = true
-- Enable the Neovim IDE plugin (https://github.com/ldelossa/nvim-ide)
conf.enable_ide = true
-- Enable Navigator
conf.enable_navigator = true
-- Enable Project manager
conf.enable_project = true
-- Enable window picker
conf.enable_picker = true
-- Enable smooth scrolling with neoscroll plugin
conf.enable_smooth_scrolling = false
-- Enable the Neotest plugin
conf.enable_neotest = true

-- PLUGINS CONFIGURATION
-- media backend, one of "ueberzug"|"viu"|"chafa"|"jp2a"|"catimg"|"none"
conf.media_backend = "jp2a"
-- Style of indentation, can be one of:
-- 'background' colored' 'context' 'listchars' 'mini' 'simple' 'none'
conf.indentline_style = "context"
-- treesitter parsers to be installed
conf.treesitter_ensure_installed = {
  "c",
  "lua",
  "vim",
  "vimdoc",
  "query",
  "cpp",
  "awk",
  "bash",
  "comment",
  "commonlisp",
  "css",
  "csv",
  "diff",
  "dockerfile",
  "dot",
  "fennel",
  "git_config",
  "git_rebase",
  "gitattributes",
  "gitcommit",
  "gitignore",
  "go",
  "gomod",
  "gosum",
  "gowork",
  "gpg",
  "graphql",
  "hcl",
  "html",
  "htmldjango",
  "http",
  "hurl",
  "ini",
  "java",
  "javascript",
  "jq",
  "jsdoc",
  "json",
  "jsonc",
  "julia",
  "latex",
  "luadoc",
  "luap",
  "make",
  "markdown",
  "markdown_inline",
  "mermaid",
  "ninja",
  "nix",
  "passwd",
  "pem",
  "perl",
  "php",
  "puppet",
  "python",
  "regex",
  "requirements",
  "robot",
  "rst",
  "ruby",
  "rust",
  "scss",
  "smithy",
  "sql",
  "terraform",
  "todotxt",
  "toml",
  "tsv",
  "tsx",
  "typescript",
  "xml",
  "yaml",
}
-- Enable clangd or ccls for C/C++ diagnostics
-- Note: if enabled then the tool must be installed and in the execution path
conf.enable_ccls = true
conf.enable_clangd = false
-- LSPs that should be installed by Mason-lspconfig
-- Leave the 'LSP_SERVERS' trailing comment, it is used by lazyman
conf.lsp_servers = {
  "awk_ls",        -- LSP_SERVERS
  "bashls",        -- LSP_SERVERS
  "cssmodules_ls", -- LSP_SERVERS
  "denols",        -- LSP_SERVERS
  "dockerls",      -- LSP_SERVERS
  -- "eslint",     -- LSP_SERVERS
  "gopls",         -- LSP_SERVERS
  "graphql",       -- LSP_SERVERS
  "helm_ls",       -- LSP_SERVERS
  "html",          -- LSP_SERVERS
  "jdtls",         -- LSP_SERVERS
  "jsonls",        -- LSP_SERVERS
  "jqls",          -- LSP_SERVERS
  "julials",       -- LSP_SERVERS
  "ltex",          -- LSP_SERVERS
  "lua_ls",        -- LSP_SERVERS
  "marksman",      -- LSP_SERVERS
  "pylsp",         -- LSP_SERVERS
  "pyright",       -- LSP_SERVERS
  "sqlls",         -- LSP_SERVERS
  "tailwindcss",   -- LSP_SERVERS
  "taplo",         -- LSP_SERVERS
  "texlab",        -- LSP_SERVERS
  "terraformls",   -- LSP_SERVERS
  "tsserver",      -- LSP_SERVERS
  "vimls",         -- LSP_SERVERS
  "yamlls",        -- LSP_SERVERS
}
-- Formatters and linters installed by Mason
conf.formatters_linters = {
  "actionlint",         -- FORMATTERS_LINTERS
  "djlint",             -- FORMATTERS_LINTERS
  "gitlint",            -- FORMATTERS_LINTERS
  "gofumpt",            -- FORMATTERS_LINTERS
  "goimports",          -- FORMATTERS_LINTERS
  "golines",            -- FORMATTERS_LINTERS
  "golangci-lint",      -- FORMATTERS_LINTERS
  "hadolint",           -- FORMATTERS_LINTERS
  "google-java-format", -- FORMATTERS_LINTERS
  "latexindent",        -- FORMATTERS_LINTERS
  -- "markdownlint",       -- FORMATTERS_LINTERS
  "prettier",           -- FORMATTERS_LINTERS
  "sql-formatter",      -- FORMATTERS_LINTERS
  "shellcheck",      -- FORMATTERS_LINTERS
  "shellharden",     -- FORMATTERS_LINTERS
  -- "shfmt",           -- FORMATTERS_LINTERS
  "stylua",          -- FORMATTERS_LINTERS
  "tflint",   -- FORMATTERS_LINTERS
  "tfsec",    -- FORMATTERS_LINTERS
  "vint",     -- FORMATTERS_LINTERS
  "yamllint", -- FORMATTERS_LINTERS
}
-- Formatters and linters installed externally
conf.external_formatters = {
  "beautysh",        -- FORMATTERS_LINTERS
  "black", -- FORMATTERS_LINTERS
  "ruff",  -- FORMATTERS_LINTERS
}
-- enable greping in hidden files
conf.telescope_grep_hidden = true
-- Show diagnostics, can be one of "none", "icons", "popup". Default is "popup"
--   "none":  diagnostics are disabled but still underlined
--   "icons": only an icon will show, use ',de' to see the diagnostic
--   "popup": an icon will show and a popup with the diagnostic will appear
conf.show_diagnostics = "popup"
-- Enable semantic highlighting
conf.enable_semantic_highlighting = true
-- Convert semantic highlights to treesitter highlights
conf.convert_semantic_highlighting = true

return conf

