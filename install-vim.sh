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

install_vim_package() {
  local name=$1
  local repository=$2
  local target=$3

  if [[ -d $target/.git ]]; then
    printf 'already installed: %s at %s\n' "$name" "$target"
    return
  fi

  if [[ -e $target || -L $target ]]; then
    printf 'cannot install %s: %s already exists and is not a Git checkout\n' "$name" "$target" >&2
    return 1
  fi

  command -v git >/dev/null 2>&1 || {
    printf 'cannot install %s: git is not installed\n' "$name" >&2
    return 1
  }

  mkdir -p -- "$(dirname -- "$target")"
  git clone --depth 1 "$repository" "$target"
  printf 'installed: %s at %s\n' "$name" "$target"
}

mkdir -p -- "$HOME/.vim/undo" "$HOME/.vim/view"
link_config "$repo_dir/conf.bash/.bashrc" "$HOME/.bashrc"
link_config "$repo_dir/init.vim" "$HOME/.vimrc"

install_vim_package \
  ALE \
  https://github.com/dense-analysis/ale.git \
  "$HOME/.vim/pack/dotfiles/start/ale"
install_vim_package \
  Vimspector \
  https://github.com/puremourning/vimspector.git \
  "$HOME/.vim/pack/dotfiles/opt/vimspector"

if (( made_backup )); then
  printf 'previous files backed up in %s\n' "$backup_dir"
fi
