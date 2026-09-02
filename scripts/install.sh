#!/bin/sh
set -eu

apply=false
if [ "${1:-}" = "--apply" ]; then
  apply=true
elif [ "$#" -gt 0 ]; then
  echo "Usage: $0 [--apply]" >&2
  exit 2
fi

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
timestamp=$(date +%Y%m%d-%H%M%S)
backup_dir="$HOME/.dotfiles-backup/$timestamp"

link_file() {
  source_path=$1
  target_path=$2

  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
    echo "ok      $target_path"
    return
  fi

  if [ "$apply" = false ]; then
    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
      echo "backup  $target_path -> $backup_dir"
    fi
    echo "link    $target_path -> $source_path"
    return
  fi

  mkdir -p "$(dirname -- "$target_path")"
  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    relative_path=${target_path#"$HOME"/}
    mkdir -p "$backup_dir/$(dirname -- "$relative_path")"
    mv "$target_path" "$backup_dir/$relative_path"
  fi
  ln -s "$source_path" "$target_path"
  echo "linked  $target_path -> $source_path"
}

link_file "$repo_dir/home/.zprofile" "$HOME/.zprofile"
link_file "$repo_dir/home/.zshrc" "$HOME/.zshrc"
link_file "$repo_dir/home/.config/git/ignore" "$HOME/.config/git/ignore"

if [ "$apply" = false ]; then
  echo
  echo "Dry run only. Re-run with --apply to make these changes."
fi
