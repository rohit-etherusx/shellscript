#!/usr/bin/env bash
# desc: Fonts — Fedora font packages + JetBrainsMono Nerd Font (powerline/icon glyphs)
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"

# Fedora equivalents of Arch-Hyprland/install-scripts/fonts.sh
install_pkgs \
  jetbrains-mono-fonts \
  fira-code-fonts \
  adobe-source-code-pro-fonts \
  google-noto-sans-fonts \
  google-noto-sans-mono-fonts \
  google-noto-emoji-fonts \
  fontawesome-fonts-all \
  || warn "Some font packages were not available (non-fatal)"

# Nerd Font — not packaged in Fedora; fetch the official release zip.
NF_NAME="JetBrainsMono"
NF_DIR="$HOME/.local/share/fonts/${NF_NAME}NerdFont"
NF_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${NF_NAME}.zip"
NF_ZIP="$BUILD_DIR/${NF_NAME}.zip"

if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
  info "JetBrainsMono Nerd Font already installed. Skipping..."
else
  download "$NF_URL" "$NF_ZIP"
  mkdir -p "$NF_DIR"
  run_logged "Extracting ${YELLOW}${NF_NAME} Nerd Font${RESET}" unzip -o -q "$NF_ZIP" -d "$NF_DIR" -x 'LICENSE*' 'README*'
  run_logged "Rebuilding font cache" fc-cache -f
  if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    ok "JetBrainsMono Nerd Font installed → $NF_DIR"
  else
    die "Nerd Font install failed (fc-list doesn't see it)"
  fi
fi
