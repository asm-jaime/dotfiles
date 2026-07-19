# Vim terminal debugging with NetCoreDbg

This repository uses one debugging path:

```text
Vim -> Vimspector -> Debug Adapter Protocol -> NetCoreDbg -> .NET process
```

Vimspector provides source navigation, breakpoints, locals, watches, threads,
call stacks, and process output inside Vim. NetCoreDbg is the C# debug adapter.
Neither tool is a completion engine.

## Requirements

- Vim 8.2.4797 or newer, built with Python 3.10+ support
- Vimspector installed at `~/.vim/pack/dotfiles/opt/vimspector`
- NetCoreDbg installed at `~/.local/bin/netcoredbg`
- A .NET project built with debug symbols

The repository installer only links the dotfiles. The README contains the
Ubuntu Vim and Vimspector installation commands. NetCoreDbg stays in
`~/.local/bin`.

Check the local setup with:

```sh
vim --version | grep -E 'VIM - Vi IMproved|\+python3|\+terminal'
~/.local/bin/netcoredbg --version
```

## Controls

| Key | Action |
| --- | --- |
| `F9` | Toggle a breakpoint on the current line |
| `F5` | Start or continue |
| `F10` | Step over |
| `F11` | Step into |
| `F12` | Step out |
| `F3` | Stop |
| `F4` | Restart the previous session |
| `F6` | Pause |

Inside a Vim terminal, `Ctrl+C` is sent to the process and `Esc` returns to
Vim Normal mode.

## Project configuration

Vimspector reads `.vimspector.json` from the project root. This example starts
a built .NET assembly and asks for an optional NUnit filter when the session
starts:

```json
{
  "configurations": {
    "Debug .NET test assembly": {
      "adapter": "netcoredbg",
      "filetypes": ["cs"],
      "variables": {
        "TestFilter": "Name=VisualFrameFromState_shuld_be_rendered_with_sprite_at_state_position"
      },
      "configuration": {
        "request": "launch",
        "program": "${workspaceRoot}/Tests/bin/Debug/net10.0/Tests.dll",
        "args": [
          "--filter",
          "${TestFilter}"
        ],
        "cwd": "${workspaceRoot}",
        "stopAtEntry": false
      }
    }
  }
}
```

Change the `TestFilter` variable for the test being debugged. NetCoreDbg starts
the managed assembly directly; the equivalent non-debugging command is:

```sh
dotnet Tests/bin/Debug/net10.0/Tests.dll \
  --filter 'Name=VisualFrameFromState_shuld_be_rendered_with_sprite_at_state_position'
```

Keep project-specific paths and test filters in the project's own
`.vimspector.json`, not in these dotfiles.

## Minimal fallback

If the Vimspector UI is not useful for a particular failure, keep Vim in one
terminal pane and run NetCoreDbg in another. Its command-line interface can set
source or method breakpoints before starting the process:

```text
break DisplayImageBuilder.cs:60
break Tank1990.DisplayImage.DisplayImageBuilder.GetBitmap
run
```

Useful upstream documentation:

- <https://puremourning.github.io/vimspector-web/>
- <https://puremourning.github.io/vimspector/configuration.html>
- <https://github.com/Samsung/netcoredbg>
