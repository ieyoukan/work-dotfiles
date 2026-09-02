#!/bin/sh
set -eu

failures=0

check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    printf 'ok      %-18s %s\n' "$1" "$(command -v "$1")"
  else
    printf 'missing %-18s\n' "$1"
    failures=$((failures + 1))
  fi
}

echo "System"
printf '        macOS: %s\n' "$(sw_vers -productVersion 2>/dev/null || echo unknown)"
printf '        arch:  %s\n' "$(uname -m)"
printf '        shell: %s\n' "${SHELL:-unknown}"

echo
echo "Commands"
for command_name in brew git gh mise uv direnv rg jq fzf bat eza shellcheck shfmt; do
  check_command "$command_name"
done

echo
echo "Safety"
for secret_path in "$HOME/.ssh" "$HOME/.config/gh/hosts.yml"; do
  if [ -e "$secret_path" ]; then
    echo "local   $secret_path (intentionally unmanaged)"
  fi
done

if [ "$failures" -gt 0 ]; then
  echo
  echo "$failures command(s) missing. Run: brew bundle --file ./Brewfile"
  exit 1
fi
