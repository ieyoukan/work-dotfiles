#!/bin/sh
set -eu

supported_apps="ghostty zed orbstack"

usage() {
  cat <<'EOF'
Usage: ./scripts/apps.sh [--list | all | APP...]

With no arguments, each app is offered interactively.

Available apps:
  ghostty   Terminal emulator
  zed       Code editor
  orbstack  Containers and Linux machines
EOF
}

is_supported() {
  for supported_app in $supported_apps; do
    [ "$1" = "$supported_app" ] && return 0
  done
  return 1
}

install_app() {
  app=$1
  if brew list --cask "$app" >/dev/null 2>&1; then
    echo "already installed: $app"
  else
    brew install --cask "$app"
  fi
}

if [ "${1:-}" = "--list" ]; then
  usage
  exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Install it first from https://brew.sh/" >&2
  exit 1
fi

if [ "${1:-}" = "all" ]; then
  shift
  [ "$#" -eq 0 ] || { usage >&2; exit 2; }
  for app in $supported_apps; do
    install_app "$app"
  done
  exit 0
fi

if [ "$#" -gt 0 ]; then
  for app in "$@"; do
    if ! is_supported "$app"; then
      echo "Unsupported app: $app" >&2
      usage >&2
      exit 2
    fi
  done
  for app in "$@"; do
    install_app "$app"
  done
  exit 0
fi

if [ ! -t 0 ]; then
  echo "Interactive selection requires a terminal. Pass app names as arguments." >&2
  usage >&2
  exit 2
fi

for app in $supported_apps; do
  printf 'Install %s? [y/N] ' "$app"
  read -r answer
  case $answer in
    y|Y|yes|YES|Yes) install_app "$app" ;;
    *) echo "skipped: $app" ;;
  esac
done
