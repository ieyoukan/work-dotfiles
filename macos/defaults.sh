#!/bin/sh
set -eu

if [ "$(uname -s)" != "Darwin" ]; then
  echo "This script supports macOS only." >&2
  exit 1
fi

echo "Applying conservative macOS defaults..."

# Finder: show useful path and filename information.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Save screenshots as PNG without window shadows.
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# Avoid creating metadata files on network and USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

killall Finder >/dev/null 2>&1 || true
killall SystemUIServer >/dev/null 2>&1 || true

echo "Done. Some changes may require logging out and back in."
