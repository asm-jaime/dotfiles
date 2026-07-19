# Ubuntu terminal dotfiles

A small Vim-only Ubuntu environment for terminal editing, linting, and .NET
debugging.

The maintained surface is intentionally narrow:

- Bash history, prompt, completion, aliases, and user-local tool paths
- Vim editing options, persistent undo/views, netrw, and terminal behavior
- ALE linting for C/C++, C#, Python, and shell files
- Vimspector debugging through NetCoreDbg
- Optional Double Commander integration with Vim and keyboard-only path copying

## Install the dotfiles

```sh
cd ~/dotfiles
./install-vim.sh
```

The script creates `~/.bashrc` and `~/.vimrc` links, Vim's undo/view
directories, and installs ALE and Vimspector in Vim's native package layout.
Existing configuration files are moved to a timestamped directory under
`~/.dotfiles-backup`. Start a new shell after installation.

For Ubuntu clipboard support and the configured linters:

```sh
sudo apt install vim-gtk3 clang clang-tidy cppcheck pylint shellcheck
```

Running `install-vim.sh` again leaves existing package checkouts in place.

## Double Commander

Start Double Commander once if this is a new installation. Then close it and
run:

```sh
./install-doublecmd.sh
```

The portable preferences live in `conf.doublecmd/settings.json`. The installer
merges that one safe file into Double Commander's native `doublecmd.xml` and
`shortcuts.scf`, backing both up first. It configures terminal Vim, safe file
operation defaults, search behavior, desktop-style Ctrl+C/V/X file-panel
hotkeys, and these path-copy shortcuts:

- `Ctrl+Shift+C`: copy the selected file or directory with its full path
- `Ctrl+Shift+P`: copy the current directory of the active panel

Histories, tabs, caches, window positions, credentials, and absolute personal
paths are neither stored nor copied.

## Total Commander

On a machine with Total Commander, close it and pass its `wincmd.ini` to:

```sh
./install-totalcmd-shortcuts.sh /path/to/wincmd.ini
```

This installs the same two shortcuts using Total Commander's native commands:
`cm_CopyFullNamesToClip` for `Ctrl+Shift+C` and `cm_CopySrcPathToClip` for
`Ctrl+Shift+P`. The existing INI is backed up first.

## Vim essentials

- `Esc` in a Vim terminal: return to Vim Normal mode
- `Ctrl+C` in Visual mode: copy the selection
- `Ctrl+C` in terminal mode: interrupt the terminal process
- `,,f`: open the netrw file browser
- `,an` / `,ap`: next / previous ALE diagnostic
- `,ad`: show the current ALE diagnostic
- `F2` on an NUnit `[Test]` method: stop at and debug only that test
- `F7`, `F8`, `F12`: step into, step over, and step out
- `F5`, `F9`, `F10`, `F11`, `F12`: continue, breakpoint, and stepping controls
- `F3`, `F4`, `F6`: stop, restart, and pause debugging

See [Vim terminal debugging](docs/VIM_TERMINAL_DEBUGGING.md) for the
NetCoreDbg/Vimspector setup and a project configuration example.

## Layout

- `init.vim` — complete Vim configuration
- `conf.bash/.bashrc` — complete interactive Bash configuration
- `install-vim.sh` — safe Bash/Vim linker and Vim package installer
- `install-doublecmd.sh` — optional focused Double Commander configurator
- `install-totalcmd-shortcuts.sh` — focused Total Commander shortcut merger
- `conf.doublecmd/settings.json` — portable Double Commander preferences
- `docs/VIM_TERMINAL_DEBUGGING.md` — debugging guide
