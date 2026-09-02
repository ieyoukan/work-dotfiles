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

unlink_if_owned() {
  source_path=$1
  target_path=$2

  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
    if [ "$apply" = true ]; then
      rm "$target_path"
      echo "removed $target_path"
    else
      echo "remove  $target_path"
    fi
  else
    echo "skip    $target_path (not a symlink owned by this repository)"
  fi
}

unlink_if_owned "$repo_dir/home/.zprofile" "$HOME/.zprofile"
unlink_if_owned "$repo_dir/home/.zshrc" "$HOME/.zshrc"
unlink_if_owned "$repo_dir/home/.vimrc" "$HOME/.vimrc"
unlink_if_owned "$repo_dir/home/.config/git/ignore" "$HOME/.config/git/ignore"

if [ "$apply" = false ]; then
  echo
  echo "Dry run only. Re-run with --apply to remove owned symlinks."
fi
