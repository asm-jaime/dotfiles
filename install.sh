#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
backup_dir="$HOME/.dotfiles-backup/$(date -u +%Y%m%dT%H%M%SZ)"
made_backup=0

link_config() {
  local source=$1
  local target=$2

  if [[ -L $target && $(readlink -f -- "$target") == $(readlink -f -- "$source") ]]; then
    printf 'already linked: %s\n' "$target"
    return
  fi

  if [[ -e $target || -L $target ]]; then
    mkdir -p -- "$backup_dir"
    mv -- "$target" "$backup_dir/${target##*/}"
    made_backup=1
  fi

  ln -s -- "$source" "$target"
  printf 'linked: %s -> %s\n' "$target" "$source"
}

mkdir -p -- "$HOME/.vim/undo" "$HOME/.vim/view"
link_config "$repo_dir/conf.bash/.bashrc" "$HOME/.bashrc"
link_config "$repo_dir/init.vim" "$HOME/.vimrc"

if (( made_backup )); then
  printf 'previous files backed up in %s\n' "$backup_dir"
fi
