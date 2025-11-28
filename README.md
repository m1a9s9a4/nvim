# Neovim Configuration

A modern, minimal Neovim configuration focused on Go and TypeScript development with a beautiful interface and efficient workflow.

## Features

- Plugin management with [lazy.nvim](https://github.com/folke/lazy.nvim)
- LSP support for Go and TypeScript via Mason
- Fuzzy finding and navigation with Snacks picker
- Git integration with Gitsigns
- Test runner for Go with Neotest
- Beautiful Kanagawa colorscheme
- Day-aware dashboard with ASCII art
- Code formatting with Conform
- File navigation with Oil.nvim
- Syntax highlighting with Treesitter

## Requirements

- Neovim >= 0.11.0
- Git
- Node.js (for TypeScript LSP)
- Go (for Go LSP)
- A Nerd Font (for icons)

## Installation

1. Clone this repository:
```bash
git clone git@github.com:m1a9s9a4/nvim.git ~/.config/nvim
```

2. Launch Neovim:
```bash
nvim
```

3. Lazy.nvim will automatically install all plugins on first launch.

## Structure

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── config/
│   │   ├── lazy.lua        # Lazy.nvim setup
│   │   ├── options.lua     # Vim options
│   │   ├── keymaps.lua     # Global keymaps
│   │   └── cheatsheet.lua  # Custom cheatsheet
│   └── plugins/
│       ├── init.lua        # Plugin loader
│       ├── lsp.lua         # LSP configuration
│       ├── snacks.lua      # Fuzzy finder & utils
│       ├── neotest.lua     # Test runner
│       ├── treesitter.lua  # Syntax highlighting
│       ├── colorscheme.lua # Theme configuration
│       ├── dashboard.lua   # Start screen
│       ├── gitsigns.lua    # Git integration
│       ├── conform.lua     # Code formatting
│       ├── oil.lua         # File explorer
│       ├── flash.nvim      # Fast navigation
│       ├── toggleterm.lua  # Terminal
│       ├── todo-comments.lua # TODO highlighting
│       └── which-key.lua   # Keybinding hints
├── lazy-lock.json          # Plugin versions
└── stylua.toml            # Lua formatter config
```

## Key Bindings

### Leader Key
- Leader: `Space`
- Local Leader: `\`

### General
- `<leader>w` - Save file and go back
- `<leader>?` - Open cheatsheet
- `:Cheat` - Open cheatsheet (command)

### File Navigation (Snacks Picker)
- `<leader>ff` - Find files
- `<leader>fg` - Grep text
- `<leader>fb` - Find buffers
- `<leader>fh` - Search help
- `<leader>fr` - Recent files
- `<leader>fc` - Find commands
- `<leader>fs` - LSP symbols
- `<leader>fS` - Workspace symbols
- `<leader>/` - Grep in open buffers
- `<leader>:` - Command history

### Git
- `<leader>gf` - Git files
- `<leader>gl` - Git log
- `<leader>gs` - Git status

### LSP
- `K` - Hover documentation
- `gd` - Go to definition
- `gr` - Find references
- `gi` - Go to implementation
- `gy` - Go to type definition
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions

### Testing (Neotest)
- `<leader>tt` - Run nearest test
- `<leader>tf` - Run file tests
- `<leader>ta` - Run all tests
- `<leader>ts` - Toggle test summary
- `<leader>to` - Show test output
- `<leader>tp` - Toggle output panel
- `<leader>tl` - Run last test
- `<leader>tw` - Watch file tests

### Picker Window Splits
- `<C-t>` - Open in new tab
- `<C-v>` - Open in vertical split
- `<C-s>` or `<C-x>` - Open in horizontal split

## Plugins

### Core
- **lazy.nvim** - Plugin manager
- **mason.nvim** - LSP/DAP/linter installer
- **nvim-lspconfig** - LSP configuration
- **nvim-treesitter** - Syntax highlighting

### UI
- **kanagawa.nvim** - Colorscheme
- **dashboard-nvim** - Start screen with day-aware ASCII art
- **snacks.nvim** - Multi-purpose utilities (picker, notifier, etc.)
- **which-key.nvim** - Keybinding hints
- **mini.icons** - Icon support
- **gitsigns.nvim** - Git decorations

### Navigation & Editing
- **flash.nvim** - Fast cursor movement
- **oil.nvim** - File explorer
- **todo-comments.nvim** - Highlight TODO comments

### Development
- **neotest** - Test runner framework
- **neotest-golang** - Go test adapter
- **conform.nvim** - Code formatter
- **toggleterm.nvim** - Terminal integration

## LSP Servers

The following LSP servers are automatically installed:
- **gopls** - Go language server
- **ts_ls** - TypeScript/JavaScript language server

## Treesitter Parsers

Configured parsers for:
- Go (go, gomod, gosum)
- TypeScript/JavaScript (typescript, tsx, javascript)
- Web (html, css, json, yaml)
- Lua
- Markdown

## Customization

### Changing Colorscheme Theme
Edit `lua/plugins/colorscheme.lua`:
```lua
opts = {
  theme = "wave", -- Options: wave, dragon, lotus
}
```

### Adding LSP Servers
Edit `lua/plugins/lsp.lua`:
```lua
ensure_installed = {
  "gopls",
  "ts_ls",
  "your_language_server", -- Add here
},
```

### Adding Treesitter Parsers
Edit `lua/plugins/treesitter.lua`:
```lua
ensure_installed = {
  -- Add your language here
},
```

## Dashboard

The dashboard displays a different ASCII art header for each day of the week (in JST timezone) and provides quick access to common actions:
- Find files
- Recent files
- Find text
- Open cheatsheet
- Edit config
- Open Lazy plugin manager

## Configuration Options

### Editor Settings
- Line numbers enabled with relative numbering
- Clipboard integration with system clipboard
- Space as leader key

## License

MIT

## Acknowledgments

This configuration uses the following excellent projects:
- [LazyVim](https://github.com/LazyVim/LazyVim) - For inspiration
- [Kanagawa](https://github.com/rebelot/kanagawa.nvim) - Beautiful colorscheme
- [Snacks.nvim](https://github.com/folke/snacks.nvim) - Swiss army knife plugin
