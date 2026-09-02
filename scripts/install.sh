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
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/work-dotfiles"
state_file="$state_dir/install-backup"

if [ -r "$state_file" ]; then
  IFS= read -r backup_dir < "$state_file"
  case $backup_dir in
    "$HOME"/.dotfiles-backup/*) ;;
    *) echo "Invalid backup path in $state_file" >&2; exit 1 ;;
  esac
fi

if [ "$apply" = true ] && [ ! -e "$state_file" ]; then
  mkdir -p "$state_dir"
  printf '%s\n' "$backup_dir" > "$state_file"
fi

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
    backup_path="$backup_dir/$relative_path"
    if [ -e "$backup_path" ] || [ -L "$backup_path" ]; then
      echo "Refusing to overwrite existing backup: $backup_path" >&2
      exit 1
    fi
    mkdir -p "$backup_dir/$(dirname -- "$relative_path")"
    mv "$target_path" "$backup_path"
  fi
  ln -s "$source_path" "$target_path"
  echo "linked  $target_path -> $source_path"
}

link_file "$repo_dir/home/.zprofile" "$HOME/.zprofile"
link_file "$repo_dir/home/.zshrc" "$HOME/.zshrc"
link_file "$repo_dir/home/.vimrc" "$HOME/.vimrc"
link_file "$repo_dir/home/.config/git/ignore" "$HOME/.config/git/ignore"

if [ "$apply" = false ]; then
  echo
  echo "Dry run only. Re-run with --apply to make these changes."
fi
