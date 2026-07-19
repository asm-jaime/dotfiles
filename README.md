# Ubuntu terminal dotfiles

A small Vim-only Ubuntu environment for terminal editing, linting, and .NET
debugging.

The maintained surface is intentionally narrow:

- Bash history, prompt, completion, aliases, and user-local tool paths
- Vim editing options, persistent undo/views, netrw, and terminal behavior
- ALE linting for C/C++, C#, Python, and shell files
- Vimspector debugging through NetCoreDbg
- Optional Double Commander integration with Vim and desktop-style file copy

## Install the dotfiles

```sh
cd ~/dotfiles
./install.sh
```

The script only creates `~/.bashrc` and `~/.vimrc` links plus Vim's undo/view
directories. Existing files are moved to a timestamped directory under
`~/.dotfiles-backup`. Start a new shell after installation.

For Ubuntu clipboard support and the configured linters:

```sh
sudo apt install vim-gtk3 clang clang-tidy cppcheck pylint shellcheck
```

Install the two optional Vim packages with Vim's native package layout:

```sh
mkdir -p ~/.vim/pack/dotfiles/start ~/.vim/pack/dotfiles/opt
git clone --depth 1 https://github.com/dense-analysis/ale.git \
  ~/.vim/pack/dotfiles/start/ale
git clone --depth 1 https://github.com/puremourning/vimspector.git \
  ~/.vim/pack/dotfiles/opt/vimspector
```

## Double Commander

Start Double Commander once if this is a new installation. Then close it and
run:

```sh
./install-doublecmd.sh
```

The portable preferences live in `conf.doublecmd/settings.json`. The installer
merges that one safe file into Double Commander's native `doublecmd.xml` and
`shortcuts.scf`, backing both up first. It configures terminal Vim, safe file
operation defaults, search behavior, and desktop-style Ctrl+C/V/X file-panel
hotkeys. Histories, tabs, caches, window positions, credentials, and absolute
personal paths are neither stored nor copied.

## Vim essentials

- `Esc` in a Vim terminal: return to Vim Normal mode
- `Ctrl+C` in Visual mode: copy the selection
- `Ctrl+C` in terminal mode: interrupt the terminal process
- `,,f`: open the netrw file browser
- `,an` / `,ap`: next / previous ALE diagnostic
- `,ad`: show the current ALE diagnostic
- `F5`, `F9`, `F10`, `F11`, `F12`: continue, breakpoint, and stepping controls
- `F3`, `F4`, `F6`: stop, restart, and pause debugging

See [Vim terminal debugging](docs/VIM_TERMINAL_DEBUGGING.md) for the
NetCoreDbg/Vimspector setup and a project configuration example.

## Layout

- `init.vim` — complete Vim configuration
- `conf.bash/.bashrc` — complete interactive Bash configuration
- `install.sh` — safe Bash/Vim linker
- `install-doublecmd.sh` — optional focused Double Commander configurator
- `conf.doublecmd/settings.json` — portable Double Commander preferences
- `docs/VIM_TERMINAL_DEBUGGING.md` — debugging guide
