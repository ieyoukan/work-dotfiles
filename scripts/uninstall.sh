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
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/work-dotfiles"
state_file="$state_dir/install-backup"
backup_dir=""
conflicts=0

if [ -r "$state_file" ]; then
  IFS= read -r backup_dir < "$state_file"
  case $backup_dir in
    "$HOME"/.dotfiles-backup/*) ;;
    *) echo "Invalid backup path in $state_file" >&2; exit 1 ;;
  esac
fi

restore_if_owned() {
  source_path=$1
  target_path=$2
  relative_path=${target_path#"$HOME"/}
  backup_path=""
  if [ -n "$backup_dir" ]; then
    backup_path="$backup_dir/$relative_path"
  fi

  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
    if [ "$apply" = true ]; then
      rm "$target_path"
      if [ -n "$backup_path" ] && { [ -e "$backup_path" ] || [ -L "$backup_path" ]; }; then
        mkdir -p "$(dirname -- "$target_path")"
        mv "$backup_path" "$target_path"
        echo "restored $target_path"
      else
        echo "removed  $target_path (no previous file)"
      fi
    elif [ -n "$backup_path" ] && { [ -e "$backup_path" ] || [ -L "$backup_path" ]; }; then
      echo "restore  $target_path <- $backup_path"
    else
      echo "remove  $target_path"
    fi
  elif { [ ! -e "$target_path" ] && [ ! -L "$target_path" ]; } && [ -n "$backup_path" ] && { [ -e "$backup_path" ] || [ -L "$backup_path" ]; }; then
    if [ "$apply" = true ]; then
      mkdir -p "$(dirname -- "$target_path")"
      mv "$backup_path" "$target_path"
      echo "restored $target_path"
    else
      echo "restore  $target_path <- $backup_path"
    fi
  elif [ -e "$target_path" ] || [ -L "$target_path" ]; then
    echo "skip     $target_path (not a symlink owned by this repository)"
    if [ -n "$backup_path" ] && { [ -e "$backup_path" ] || [ -L "$backup_path" ]; }; then
      echo "conflict backup remains at $backup_path" >&2
      conflicts=1
    fi
  else
    echo "skip     $target_path (already absent)"
  fi
}

restore_if_owned "$repo_dir/home/.zprofile" "$HOME/.zprofile"
restore_if_owned "$repo_dir/home/.zshrc" "$HOME/.zshrc"
restore_if_owned "$repo_dir/home/.vimrc" "$HOME/.vimrc"
restore_if_owned "$repo_dir/home/.config/git/ignore" "$HOME/.config/git/ignore"

if [ "$apply" = false ]; then
  echo
  echo "Dry run only. Re-run with --apply to restore the previous files."
elif [ "$conflicts" -eq 0 ] && [ -e "$state_file" ]; then
  rm "$state_file"
  rmdir "$state_dir" 2>/dev/null || true
elif [ "$conflicts" -gt 0 ]; then
  echo "Uninstall completed with conflicts; install state was retained." >&2
  exit 1
fi
