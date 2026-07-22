#!/usr/bin/env bash
set -euo pipefail

selected_file=${1-}
if [[ -z $selected_file ]]; then
  printf 'No file was selected.\n' >&2
  exit 2
fi

if [[ ! -e $selected_file ]]; then
  printf 'Selected file does not exist: %s\n' "$selected_file" >&2
  exit 2
fi
selected_file=$(realpath -- "$selected_file")

tmux_bin=$(command -v tmux)
terminal_bin=${DOTFILES_DEBUG_TERMINAL:-$(command -v gnome-terminal)}
vim_bin=$(command -v vim)
working_dir=$(dirname -- "$selected_file")

session_number=1
while :; do
  session_name="debug-$session_number"

  if "$tmux_bin" has-session -t "$session_name" 2>/dev/null; then
    ((session_number += 1))
    continue
  fi

  if "$tmux_bin" new-session -d -s "$session_name" -c "$working_dir" \
      -e "DOTFILES_DEBUG_FILE=$selected_file" \
      "exec $vim_bin -- \"\$DOTFILES_DEBUG_FILE\"" 2>/dev/null; then
    break
  fi

  # A simultaneous launch may have claimed this name after has-session.
  if "$tmux_bin" has-session -t "$session_name" 2>/dev/null; then
    ((session_number += 1))
    continue
  fi

  printf 'Could not create tmux session %s.\n' "$session_name" >&2
  exit 1
done

cleanup_session() {
  "$tmux_bin" kill-session -t "$session_name" 2>/dev/null || true
}
trap cleanup_session ERR INT TERM

"$tmux_bin" set-option -t "$session_name" status on
"$tmux_bin" set-option -t "$session_name" status-position bottom
"$tmux_bin" set-option -t "$session_name" status-style 'fg=colour252,bg=colour234'
"$tmux_bin" set-option -t "$session_name" status-left '#[bold,fg=colour81][#{session_name}]#[default] '
"$tmux_bin" set-option -t "$session_name" status-left-length 32
"$tmux_bin" set-option -t "$session_name" status-right ''
"$tmux_bin" set-option -t "$session_name" status-right-length 0
"$tmux_bin" set-option -t "$session_name" window-status-format '#I:#W'
"$tmux_bin" set-option -t "$session_name" window-status-current-format '#[bold]#I:#W*'
"$tmux_bin" set-option -t "$session_name" set-titles on
"$tmux_bin" set-option -t "$session_name" set-titles-string '[#S] #W'

"$terminal_bin" --title="tmux: $session_name" -- \
  "$tmux_bin" attach-session -t "$session_name"

trap - ERR INT TERM
